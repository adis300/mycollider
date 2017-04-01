package main

import (
	"flag"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/kardianos/osext"
)

var currentDir = ""

// If debug set foundCurrentDir to true
var foundCurrentDir = DEBUG_MODE

func determineWorkingDirectory() {
	var customPath string
	// Check if a custom path has been provided by the user.
	flag.StringVar(&customPath, "custom-path", "", "Specify a custom path to the asset files. This needs to be an absolute path.")
	flag.Parse()
	// Get the absolute path this executable is located in.
	executablePath, err := osext.ExecutableFolder()
	if err != nil {
		log.Fatal("Error: Couldn't determine working directory: " + err.Error())
	}
	// Set the working directory to the path the executable is located in.
	os.Chdir(executablePath)
	currentDir = executablePath
	foundCurrentDir = true
}

// GetAbsolutePath returns the absolute path of a file
func GetAbsolutePath(relPath string) string {
	if !foundCurrentDir {
		determineWorkingDirectory()
	}
	return filepath.Join(currentDir, relPath)
}

// LoadFile loads a file data in to a byte array
func LoadFile(relPath string) []byte {
	if !foundCurrentDir {
		determineWorkingDirectory()
	}
	data, _ := ioutil.ReadFile(filepath.Join(currentDir, relPath))
	return data
}

// LoadView is a wrapper around LoadFile to load templates
func LoadView(templateName string) []byte {
	relPath := "view/" + templateName + ".html"
	return LoadFile(relPath)
}
