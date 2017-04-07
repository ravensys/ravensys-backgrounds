THEMENAME = ravensys
VERSION = $(shell date '+%Y%m%d')

LOGOWIDTH = 4096
LOGOHEIGHT = 1280
LOGOALPHA = 66

theme-dir = /usr/share/backgrounds/$(THEMENAME)
theme-file = $(THEMENAME).xml

#TODO implement optional gnome build / installation
ENABLE_GNOME = 1
gnome-theme-dir = /usr/share/gnome-background-properties
gnome-theme-file = gnome-backgrounds-$(THEMENAME).xml

supported-formats = normalish standard tv-wide wide
background-files = $(addsuffix /$(THEMENAME).png,$(supported-formats))

normalish-height = 3072
normalish-width = 3840

standard-height = 3072
standard-width = 4096

tv-wide-height = 2160
tv-wide-width = 3840

wide-height = 2400
wide-width = 3840

dist-filename = $(THEMENAME)-backgrounds
dist-files += $(addprefix $(srcdir)/, $(source-files))
dist-files += Makefile
dist-files += Attribution
dist-files += CC-BY-SA-4.0
dist-files += LICENSE
#TODO add README file
#dist-files += README.md
dist-archive = $(dist-filename).tar.gz $(dist-filename).tar.xz

release-filename = $(THEMENAME)-backgrounds-$(VERSION)
release-files += $(background-files)
release-files += $(theme-file)
release-files += $(gnome-theme-file)
release-files += Attribution
release-files += CC-BY-SA-4.0
release-archive = $(release-filename).tar.gz $(release-filename).tar.xz

srcdir = src

source-files += backgrounds.xml.in
source-files += gnome-backgrounds.xml.in
source-files += logo.svgz
source-files += texture.png

OBJDIR = obj
VPATH = $(srcdir)

.PHONY: all
all: $(background-files) $(theme-file) $(gnome-theme-file)

.PHONY: install
install:
	install -d -m 0755 $(DESTDIR)$(theme-dir)
	install -m 0644 $(theme-file) $(DESTDIR)$(theme-dir)
	install -d -m 0755 $(addprefix $(DESTDIR)$(theme-dir)/,$(supported-formats))
	for f in $(background-files); do \
		install -m 0644 $${f} $(DESTDIR)$(theme-dir)/$${f}; \
	done;
	install -m 0644 $(gnome-theme-file) $(gnome-theme-dir)/$(theme-file)

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(theme-dir)/$(theme-file)
	rm -f $(addprefix $(DESTDIR)$(theme-dir)/,$(background-files))
	rm -rf $(addprefix $(DESTDIR)$(theme-dir)/,$(supported-formats))
	rm -rf $(DESTDIR)$(theme-dir)
	rm -f $(DESTDIR)$(gnome-theme-dir)/$(theme-file)

.PHONY: clean
clean:
	rm -f $(background-files)
	rm -f $(theme-file)
	rm -rf $(supported-formats)
	rm -rf $(OBJDIR)
	rm -f $(gnome-theme-file)

.PHONY: cleanall
cleanall: clean
	rm -f $(dist-archive)
	rm -f $(release-archive)

.PHONY: dist
dist: $(dist-archive)

.PHONY: release
release: $(release-archive)

$(background-files): %/$(THEMENAME).png: texture.png $(OBJDIR)/logo.png | %
	convert \( "$<" -gravity center -crop "$($*-width)x$($*-height)+0+0" \) \
		\( "$(OBJDIR)/logo.png" -alpha on -channel a -evaluate subtract "$(LOGOALPHA)%" -resize $$(( $($*-width) * 33 / 100 )) \) \
		-gravity center -composite png32:"$@"

$(supported-formats):
	mkdir -p "$@"

$(theme-file): backgrounds.xml.in
	sed \
		-e "s#@DATE_YEAR@#$$(date '+%Y')#" \
		-e "s#@DATE_MONTH@#$$(date '+%m')#" \
		-e "s#@DATE_DAY@#$$(date '+%d')#" \
		-e "s#@NORMALISH_IMAGE@#$(theme-dir)/normalish/$(THEMENAME).png#" \
		-e "s#@STANDARD_IMAGE@#$(theme-dir)/standard/$(THEMENAME).png#" \
		-e "s#@TVWIDE_IMAGE@#$(theme-dir)/tv-wide/$(THEMENAME).png#" \
		-e "s#@WIDE_IMAGE@#$(theme-dir)/wide/$(THEMENAME).png#" \
		"$<" > "$@"

$(gnome-theme-file): gnome-backgrounds.xml.in
	sed \
		-e "s#@THEME_NAME@#$(THEMENAME)#" \
		-e "s#@THEME_FILE@#$(theme-dir)/$(theme-file)#" \
		"$<" > "$@"

$(OBJDIR)/logo.png: logo.svgz | $(OBJDIR)
	inkscape -z -e "$@" -w "$(LOGOWIDTH)" -h "$(LOGOHEIGHT)" "$<"

$(OBJDIR):
	mkdir -p "$@"

$(dist-filename).tar.gz: $(dist-files)
	tar -czf "$@" --transform "s/^\./$(dist-filename)/" $(addprefix ./,$^)

$(dist-filename).tar.xz: $(dist-files)
	tar -cJf "$@" --transform "s/^\./$(dist-filename)/" $(addprefix ./,$^)

$(release-filename).tar.gz: $(release-files)
	tar -czf "$@" --transform "s/^\./$(release-filename)/" $(addprefix ./,$^)

$(release-filename).tar.xz: $(release-files)
	tar -cJf "$@" --transform "s/^\./$(release-filename)/" $(addprefix ./,$^)

