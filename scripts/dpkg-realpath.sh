#!/bin/sh
#
# Copyright © 2020 Helmut Grohne <helmut@subdivi.de>
# Copyright © 2020 Guillem Jover <guillem@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

PROGNAME=$(basename "$0")
version="unknown"

PKGDATADIR=scripts/sh

. "$PKGDATADIR/dpkg-error.sh"

show_version()
{
  cat <<END
Debian $PROGNAME version $version.

This is free software; see the GNU General Public License version 2 or
later for copying conditions. There is NO warranty.
END
}

show_usage()
{
  cat <<END
Usage: $PROGNAME [<option>...] <pathname>

Options:
       --version      Show the version.
  -?,  --help         Show this help message.
END
}

canonicalize() {
  local src="$1"
  local root="$2"
  local loop=0
  local result="$root"
  local dst

  if [ "${src#"$root"}" = "$src" ]; then
    error "link not within root"
  fi
  # Remove prefixed root dir.
  src=${src#"$root"}
  # Remove prefixed slashes.
  while [ "$src" != "${src#/}" ]; do
     src=${src#/}
  done
  while [ -n "$src" ]; do
    loop=$((loop + 1))
    if [ "$loop" -gt 25 ]; then
      error "too many levels of symbolic links"
    fi
    # Get the first directory component.
    prefix=${src%%/*}
    # Remove the first directory component from src.
    src=${src#"$prefix"}
    # Remove prefixed slashes.
    while [ "$src" != "${src#/}" ]; do
      src=${src#/}
    done
    # Resolve the first directory component.
    if [ "$prefix" = . ]; then
      # Ignore, stay at the same directory.
      :
    elif [ "$prefix" = .. ]; then
      # Go up one directory.
      result=${result%/*}
      if [ "${result#"$root"}" = "$result" ]; then
        result="$root"
      fi
    elif [ -h "$result/$prefix" ]; then
      # Resolve the symlink within $result.
      dst=$(readlink "$result/$prefix")
      case "$dst" in
      /*)
        # Absolute pathname, reset result back to $root.
        result=$root
        src="$dst${src:+/$src}"
        # Remove prefixed slashes.
        while [ "$src" != "${src#/}" ]; do
          src=${src#/}
        done
        ;;
      *)
        # Relative pathname.
        src="$dst${src:+/$src}"
        ;;
      esac
    else
      # Otherwise append the prefix.
      result="$result/$prefix"
    fi
  done
  # We are done, print the resolved pathname, w/o $root.
  result="${result#"$root"}"
  echo "${result:-/}"
}

setup_colors

[ $# -eq 1 ] || badusage "missing pathname"

while [ $# -ne 0 ]; do
  case "$1" in
  --version)
    show_version
    exit 0
    ;;
  --help|-\?)
    show_usage
    exit 0
    ;;
  --)
    shift
    pathname="$1"
    ;;
  --*)
    badusage "unknown option: $1"
    ;;
  *)
    pathname="$1"
    ;;
  esac
  shift
done

canonicalize "$pathname" "${DPKG_ROOT:-}"

exit 0