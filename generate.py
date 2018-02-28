#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json

import tcd

from mako.lookup import TemplateLookup


def load_json(filename):
    with open(filename, "r") as f:
        return json.load(f)


if __name__ == "__main__":
    lookup = TemplateLookup(directories=['./templates'],
                            module_directory='/tmp/mako_modules',
                            input_encoding='utf-8')

    args = {"config": load_json('config.json')}
    for data in ['games', 'categories', 'streams']:
        args[data] = load_json("data/{}.json".format(data))

    # Populate games with streams info
    for game in args['games']:
        for stream in game['streams']:
            stream_info = args['streams'][stream['twitch']]
            if type(stream_info) is dict:
                stream.update(stream_info)
            elif type(stream_info) is list:
                if not stream.get('segment'):
                    stream.update(stream_info[0])
                else:
                    stream.update(stream_info[stream['segment']])

    # Populate categories with games
    for category in args['categories']:
        category['games'] = []
        for game in args['games']:
            if category['code'] == game['category']:
                category['games'].append(game)

    # Create required directores
    for directory in ['chats', 'links', 'src']:
        if not os.path.isdir(directory):
            os.mkdir(directory)

    # Download missing stream subtitles
    for stream in args['streams']:
        if not os.path.isfile("chats/v{0}.ass".format(stream)):
            tcd.download(stream)

    # Generate index.html
    with open("index.html", "w+") as out:
        t = lookup.get_template('/index.mako')
        out.write(t.render(**args))

    # Generate src/player.html for backward compatibility
    with open("src/player.html", "w+") as output:
        t = lookup.get_template('/redirect.mako')
        output.write(t.render(**args).strip())

    # # Generate links/*.md
    t = lookup.get_template('/links.mako')
    for game in args['games']:
        filename = "links/{0[filename]}".format(game)
        with open(filename, "w+") as out:
            out.write(t.render(game=game, **args).strip())
