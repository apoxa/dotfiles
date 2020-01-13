#!/usr/bin/env python3

import iterm2
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("theme", help="set default iterm2 theme")
args = parser.parse_args()


async def main(connection):
    preset = await iterm2.ColorPreset.async_get(
                connection,
                args.theme.title() + " Background")
    if not preset:
        return

    profiles = await iterm2.PartialProfile.async_query(connection)
    for partial in profiles:
        profile = await partial.async_get_full_profile()
        if profile.name == 'Default':
            await profile.async_set_color_preset(preset)

iterm2.run_until_complete(main)
