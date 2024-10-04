#!/usr/bin/env ruby
#
#   Copyright
#
#       Copyright (C) 2014-2024 Jari Aalto <jari.aalto@cante.net>
#       Copyright (C) 2007 Peter Hutterer <peter.hutterer@who-t.net>
#       Copyright (C) 2007 Benjamin Close <Benjamin.Close@clearchain.com>
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#  Description
#
#       Splitpatch is a utility to split a patch up into
#       multiple patch files. If the --hunks option is provided on the
#       command line, each hunk is saved on its own patch file.

PROGRAM = "splitpatch"
VERSION = 1.2
LICENSE = "GPL-2.0-or-later"  # See official acronyms: https://spdx.org/licenses/
HOMEPAGE = "https://github.com/jaalto/splitpatch"

class Splitter
    def initialize(file, encode)
       @encode = encode
       @filename = file
       @fullname = false
    end

    def fullname(opt)
       @fullname = opt
    end

    def validFile?
        return File.exist?(@filename) && File.readable?(@filename)
    end

    def createFile(filename)
        if File.exist?(filename)
            puts "File #{filename} already exists. Renaming patch."
            appendix = 0
            zero = appendix.to_s.rjust(3, '0')

            while File.exist?("#{filename}.#{zero}")
                appendix += 1
                zero = appendix.to_s.rjust(3, '0')
            end

            filename << ".#{zero}"
        end
        return open(filename, "w")
    end

    def getFilenameByHeader(header)
      filename = getFilename(header[0])

      if (@fullname && filename == 'dev-null') ||
             (! @fullname && filename == 'null')
        filename = getFilename(header[1])
      end

      filename
    end

    def getFilename(line)
        tokens = line.split(" ")
        tokens = tokens[1].split(":")
        tokens = tokens[0].split("/")

        if @fullname
            tokens.reject!(&:empty?)
            return tokens.join('-')
        else
            return tokens[-1]
        end
    end

    # Split the patchfile by files
    def splitByFile
        legacy = false
        outfile = nil
        stream = open(@filename, 'rb')

        until (stream.eof?)
            line = stream.readline

            # We need to create a new file
            if (line =~ /^Index: .*/) == 0
                # Patch includes Index lines
                # Drop into "legacy mode"
                legacy = true

                if (outfile)
                    outfile.close_write
                end

                filename = getFilename(line)
                filename << ".patch"
                outfile = createFile(filename)
                outfile.write(line)
            elsif (line =~ /--- .*/) == 0 and not legacy
                if (outfile)
                    outfile.close_write
                end

                # Find filename
                # Next line is header too
                header = [ line, stream.readline ]
                filename = getFilenameByHeader(header)
                filename << ".patch"

                outfile = createFile(filename)
                outfile.write(header.join(''))
            else
                if outfile
                    outfile.write(line)
                end
            end
        end
    end

    def splitByHunk
        legacy = false
        outfile = nil
        stream = open(@filename, 'rb')
        filename = ""
        counter = 0
        header = []

        until (stream.eof?)
            line = stream.readline.encode("UTF-8", @encode)

            # We need to create a new file
            if (line =~ /^Index: .*/) == 0
                # Patch includes Index lines
                # Drop into "legacy mode"
                legacy = true
                filename = getFilename(line)
                header << line

                # Remaining 3 lines of header
                for i in 0..2
                    line = stream.readline
                    header << line
                end

                counter = 0
            elsif (line =~ /--- .*/) == 0 and not legacy
                #find filename
                # next line is header too
                header = [ line, stream.readline ]
                filename = getFilenameByHeader(header)
                counter = 0
            elsif (line =~ /@@ .* @@/) == 0
                if (outfile)
                    outfile.close_write
                end

                zero = counter.to_s.rjust(3, '0')
                hunkfilename = "#{filename}.#{zero}.patch"
                outfile = createFile(hunkfilename)
                counter += 1

                outfile.write(header.join(''))
                outfile.write(line)
            else
                if outfile
                    outfile.write(line)
                end
            end
        end
    end

end

def help
    puts <<EOF
SYNOPSIS
    #{PROGRAM} [options] FILE.patch

OPTIONS
    -e=ENCODING, --encode=ENCODING
        Read file and save patch hunks using ENCODING. Default is 'UTF-8'.

    -f, --fullname
        Use full name upon saving patch hunks

    -h, --help
        Show short help. This page.

    -H, --hunk
        Split by hunks.

    -V, --version
        Display version, licence and homepage.

DESCRIPTION

    Split the patch up into files or hunks

    Divide a patch or diff file into pieces. The split can made by file
    or by hunk basis. This makes it possible to separate changes that
    might not be desirable or assemble the patch into a more coherent set
    of changes. See e.g. combinediff(1) from patchutils package.

    Note: only patches in unified format are recognized.

AUTHORS

    Peter Hutterer (orig. Author) <peter.hutterer@who-t.net>
    Benjamin Close (orig. Author) <Benjamin.Close@clearchain.com>
    Jari Aalto (Maintainer) <jari.aalto@cante.net>"

    Homepage: #{HOMEPAGE}
EOF
end

def version
  puts "#{VERSION} #{LICENSE} #{HOMEPAGE}"
end

def parsedOptions
    if ARGV.length < 1
        puts "ERROR: missing argument. See --help."
        exit 1
    end

    opts = {
        encode: "UTF-8"
    }

    ARGV.each do |opt|
    case opt
        when /^-e=(.+?)$/, /^--encode=(.+?)$/
            opts[:encode] = $~[1]
        when /^-f$/, /--fullname/
            opts[:fullname] = true
        when /^-h$/, /--help/
            opts[:help] = true
        when /^-H$/, /--hunks?/
            opts[:hunk] = true
        when /^-V$/, /--version/
            opts[:version] = true
        when /^-/
            puts "ERROR: Unknown option: #{opt}. See --help."
            exit 1
        else
            opts[:file] = opt
        end
    end

    return opts
end

def main
    opts = parsedOptions

    if opts[:help]
        help
        exit
    end

    if opts[:version]
        version
        exit
    end

    s = Splitter.new(opts[:file], opts[:encode])
    s.fullname(true) if opts[:fullname]

    if !s.validFile?
        puts "File does not exist or is not readable: #{opts[:file]}"
    end

    if opts[:hunk]
        s.splitByHunk
    else
        s.splitByFile
    end
end

main

# End of file
