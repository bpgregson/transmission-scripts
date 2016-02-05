#!/bin/sh
rm /media/nas/PostProcessing/Watch/bbb_sunflower_1080p_30fps_normal.mp4  # single file test torrent
rm -r /media/nas/PostProcessing/Watch/The.Shannara.Chronicles.S01E01-E02.HDTV.480p.x264.AAC-VYTO\ \[P2PDL.com\]/  # directory test torrent
transmission-remote -t 88594aaacbde40ef3e2510c47374ec0aa396c08e --remove-and-delete  # hash bbb_sunflower_1080p_30fps_normal.mp4
transmission-remote -t ae23c014a1226ce079657092949080f5f726f50b --remove-and-delete  # hash The.Shannara.Chronicles.S01E01-E02.HDTV.480p.x264.AAC-VYTO\ \[P2PDL.com\]
