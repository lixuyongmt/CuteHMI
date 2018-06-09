import qbs
import qbs.Environment
import qbs.Utilities

import "functions.js" as Functions

/**
  This module generates 'plugins.qmltypes' artifact.
  */
Module {
	additionalProductTypes: ["qmltypes"]

	Depends { name: "Qt.core" }

	Depends { name: "cutehmi.dirs" }

	Rule {
//<workaround id="qbs-cutehmi-qmltypes-1" target="qmlplugindump" cuase="QTBUG-66669">
		condition: qbs.targetOS.contains("windows")
//</workaround>

		multiplex: true
		inputs: ["qml", "dynamiclibrary"]

		prepare: {
			var dumpCmd = new Command(product.Qt.core.binPath + "/qmlplugindump", ["-nonrelocatable", product.name, product.major + "." + product.minor, "QML"]);
			dumpCmd.workingDirectory = product.qbs.installRoot
			var paths = product.cpp.libraryPaths.concat([product.qbs.installRoot + "/" + product.cutehmi.dirs.moduleInstallDir]).join(product.qbs.pathListSeparator)
			if (product.qbs.targetOS.contains("windows"))
				dumpCmd.environment = ["PATH=" + Environment.getEnv("PATH") + product.qbs.pathListSeparator + paths]
			else if (product.qbs.targetOS.contains("macos"))
				dumpCmd.environment = ["DYLD_LIBRARY_PATH=" + Environment.getEnv("DYLD_LIBRARY_PATH") + product.qbs.pathListSeparator + paths]
			else
				dumpCmd.environment = ["LD_LIBRARY_PATH=" + Environment.getEnv("LD_LIBRARY_PATH") + product.qbs.pathListSeparator + paths]
			dumpCmd.description = "invoking 'qmlplugindump' program to generate " + product.sourceDirectory + "/plugins.qmltypes";
			dumpCmd.highlight = "codegen"
			dumpCmd.stdoutFilePath = product.sourceDirectory + "/plugins.qmltypes"
			return [dumpCmd]
		}

		Artifact {
			filePath: product.sourceDirectory + "/plugins.qmltypes"
			fileTags: ["qmltypes"]
		}
	}
}