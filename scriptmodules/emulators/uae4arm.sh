#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="uae4arm"
rp_module_desc="Amiga emulator with JIT support"
rp_module_help="ROM Extension: .adf\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_section="opt"
rp_module_flags="!x86 !mali"

function depends_uae4arm() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libsdl-ttf2.0-dev libguichan-dev libmpg123-dev libxml2-dev libflac-dev
}

function sources_uae4arm() {
    gitPullOrClone "$md_build" https://github.com/Chips-fr/uae4arm-rpi/
}

function build_uae4arm() {
    make clean
    if isPlatform "rpi1"; then
        CXXFLAGS="" make PLATFORM=rpi1
    else
        CXXFLAGS="" make PLATFORM=rpi2
    fi
    md_ret_require="$md_build/uae4arm"
}

function install_uae4arm() {
    md_ret_files=(
        'data'
        'uae4arm'
    )
}

function configure_uae4arm() {
    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/$md_id"

    # move config / save folders to $md_conf_root/amiga/$md_id
    local dir
    for dir in conf savestates screenshots; do
        moveConfigDir "$md_inst/$dir" "$md_conf_root/amiga/$md_id/$dir"
    done

    # and kickstart dir (removing old symlinks first)
    if [[ ! -h "$md_inst/kickstarts" ]]; then
        rm -f "$md_inst/kickstarts/"{kick12.rom,kick13.rom,kick20.rom,kick31.rom}
    fi
    moveConfigDir "$md_inst/kickstarts" "$biosdir"

    cat > "$romdir/amiga/+Start UAE4Arm.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./uae4arm
popd
_EOF_
    chmod a+x "$romdir/amiga/+Start UAE4Arm.sh"
    chown $user:$user "$romdir/amiga/+Start UAE4Arm.sh"

    addEmulator 1 "$md_id" "amiga" "bash $romdir/amiga/+Start\ UAE4Arm.sh"
    addSystem "amiga"
}
