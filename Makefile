.PHONY: all

all: Bergmann-Raffel.pdf Hysneli-Rafii.pdf Pali-Boeck.pdf Reck-Font.pdf Rosenzweig-Jiang.pdf Ssenyonga-Huang.pdf

%.pdf: %/report.md
	pandoc $(basename $@)/report.md  -V geometry:margin=1in -o $@

Hysneli-Rafii.pdf: Hysneli-Rafii/reportREPET.md
	pandoc $(basename $@)/reportREPET.md  -V geometry:margin=1in -o $@
