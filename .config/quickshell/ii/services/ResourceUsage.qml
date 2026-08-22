pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    id: root
	property real memoryTotal: 0
	property real memoryFree: 0
	property real memoryUsed: Math.max(0, memoryTotal - memoryFree)
    property real memoryUsedPercentage: memoryTotal > 0 ? (memoryUsed / memoryTotal) : 0
    property real swapTotal: 0
	property real swapFree: 0
	property real swapUsed: Math.max(0, swapTotal - swapFree)
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property var previousCpuStats

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        if (!kb || kb <= 0) return "--";
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }

    function parseMeminfo() {
        const textMeminfo = fileMeminfo.text()
        if (!textMeminfo || textMeminfo.length === 0) return

        const memTotalMatch = textMeminfo.match(/MemTotal:\s*(\d+)/)
        const memAvailMatch = textMeminfo.match(/MemAvailable:\s*(\d+)/)
        const swapTotalMatch = textMeminfo.match(/SwapTotal:\s*(\d+)/)
        const swapFreeMatch = textMeminfo.match(/SwapFree:\s*(\d+)/)

        if (memTotalMatch) {
            root.memoryTotal = Number(memTotalMatch[1])
            if (memAvailMatch) {
                root.memoryFree = Number(memAvailMatch[1])
            } else {
                const memFreeMatch = textMeminfo.match(/MemFree:\s*(\d+)/)
                const buffersMatch = textMeminfo.match(/Buffers:\s*(\d+)/)
                const cachedMatch = textMeminfo.match(/^Cached:\s*(\d+)/m)
                const free = Number(memFreeMatch?.[1] ?? 0)
                const buffers = Number(buffersMatch?.[1] ?? 0)
                const cached = Number(cachedMatch?.[1] ?? 0)
                root.memoryFree = free + buffers + cached
            }
        }

        if (swapTotalMatch) {
            root.swapTotal = Number(swapTotalMatch[1])
            root.swapFree = Number(swapFreeMatch?.[1] ?? 0)
        }
    }

    function parseStat() {
        const textStat = fileStat.text()
        if (!textStat || textStat.length === 0) return

        const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
        if (cpuLine) {
            const stats = cpuLine.slice(1).map(Number)
            const total = stats.reduce((a, b) => a + b, 0)
            const idle = stats[3]

            if (previousCpuStats) {
                const totalDiff = total - previousCpuStats.total
                const idleDiff = idle - previousCpuStats.idle
                cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
            }

            previousCpuStats = { total, idle }
        }
    }

	Timer {
		interval: Config.options?.resources?.updateInterval ?? 3000
        running: true 
        repeat: true
        triggeredOnStart: true
		onTriggered: {
            fileMeminfo.reload()
            fileStat.reload()
        }
	}

	FileView {
        id: fileMeminfo
        path: "/proc/meminfo"
        onLoaded: {
            root.parseMeminfo()
            root.updateMemoryUsageHistory()
            root.updateSwapUsageHistory()
        }
        onFileChanged: {
            root.parseMeminfo()
        }
    }

    FileView {
        id: fileStat
        path: "/proc/stat"
        onLoaded: {
            root.parseStat()
            root.updateCpuUsageHistory()
        }
        onFileChanged: {
            root.parseStat()
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
