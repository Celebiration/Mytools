#!/usr/local/anaconda/envs/circleseq/bin/python
from __future__ import print_function

import svgwrite
import os
import logging
import argparse

### 2017-October-11: Adapt plots to new output; inputs are managed using "argparse".

logger = logging.getLogger('root')
logger.propagate = False

boxWidth = 10
box_size = 15
v_spacing = 3

colors = {'G': '#F5F500', 'A': '#FF5454', 'T': '#00D118', 'C': '#26A8FF', 'N': '#B3B3B3', '-': '#B3B3B3'}

def parseSitesFile(infile):
	offtargets = []
	total_seq = 0
	with open(infile, 'r') as f:
		f.readline()
		for line in f:
			line = line.rstrip('\n')
			line_items = line.split('\t')
			offtarget_reads = line_items[0]
			no_bulge_offtarget_sequence = ''
			bulge_offtarget_sequence = line_items[1]
			realigned_target_seq = line_items[2]
			position = line_items[3]
			overhang = line_items[4]

			if no_bulge_offtarget_sequence != '' or bulge_offtarget_sequence != '':
				if no_bulge_offtarget_sequence:
					total_seq += 1
				if bulge_offtarget_sequence:
					total_seq += 1
				offtargets.append({'seq': no_bulge_offtarget_sequence.strip(),
								   'bulged_seq': bulge_offtarget_sequence.strip(),
								   'reads': float(offtarget_reads.strip()),
								   'target_seq': realigned_target_seq.strip(),
								   'realigned_target_seq': realigned_target_seq.strip(),
								   'position': position.strip(),
								   'overhang': int(overhang.strip())
								   })
	offtargets = sorted(offtargets, key=lambda x: (-x['overhang'],x['reads']), reverse=True)
	return offtargets, total_seq


def visualizeOfftargets(infile, outfile, title, target_seq):

	# output_folder = os.path.dirname(outfile)
	# if not os.path.exists(output_folder):
	# 	os.makedirs(output_folder)

	# Get offtargets array from file
	offtargets, total_seq = parseSitesFile(infile)

	# Initiate canvas
	dwg = svgwrite.Drawing(outfile + '.svg', profile='full', size=(u'100%', 100 + total_seq*(box_size + 1)))

	if title is not None:
		# Define top and left margins
		x_offset = 20
		y_offset = 50
		dwg.add(dwg.text(title, insert=(x_offset, 30), style="font-size:20px; font-family:Courier"))
	else:
		# Define top and left margins
		x_offset = 20
		y_offset = 20

	# Draw ticks
	if target_seq.find('N') >= 0:
		p = target_seq.index('N')
		if p > len(target_seq) / 2:  # PAM on the right end
			tick_locations = [1, len(target_seq)] + range(p, len(target_seq))  # limits and PAM
			tick_locations += [x + p - 20 + 1 for x in range(p)[::10][1:]]  # intermediate values
			tick_locations = list(set(tick_locations))
			tick_locations.sort()
			tick_legend = [p, 10, 1] + ['P', 'A', 'M']
		else:
			tick_locations = range(2, 6) + [14, len(target_seq)]  # complementing PAM and limits
			tick_legend = ['P', 'A', 'M', '1', '10'] + [str(len(target_seq) - 4)]

		for x, y in zip(tick_locations, tick_legend):
			dwg.add(dwg.text(y, insert=(x_offset + (x - 1) * box_size + 2, y_offset - 2), style="font-size:10px; font-family:Courier"))
	else:
		tick_locations = [1, len(target_seq)]  # limits
		tick_locations += range(len(target_seq) + 1)[::10][1:]
		tick_locations.sort()
		for x in tick_locations:
			dwg.add(dwg.text(str(x), insert=(x_offset + (x - 1) * box_size + 2, y_offset - 2), style="font-size:10px; font-family:Courier"))

	# Draw reference sequence row
	for i, c in enumerate(target_seq):
		y = y_offset
		x = x_offset + i * box_size
		dwg.add(dwg.rect((x, y), (box_size, box_size), fill=colors[c]))
		dwg.add(dwg.text(c, insert=(x + 3, y + box_size - 3), fill='black', style="font-size:15px; font-family:Courier"))
	dwg.add(dwg.text("Score", insert=(x_offset + box_size * len(target_seq) + 16, y_offset + box_size - 3), style="font-size:15px; font-family:Courier"))
	dwg.add(dwg.text("Id", insert=(x_offset + box_size * len(target_seq) + 80, y_offset + box_size - 3), style="font-size:15px; font-family:Courier"))
	dwg.add(dwg.text("Overhang", insert=(x_offset + box_size * len(target_seq) + 250, y_offset + box_size - 3), style="font-size:15px; font-family:Courier"))
	# Draw aligned sequence rows
	y_offset += 1  # leave some extra space after the reference row
	line_number = 0  # keep track of plotted sequences
	for j, seq in enumerate(offtargets):
		realigned_target_seq = offtargets[j]['realigned_target_seq']
		no_bulge_offtarget_sequence = offtargets[j]['seq']
		bulge_offtarget_sequence = offtargets[j]['bulged_seq']

		if no_bulge_offtarget_sequence != '':
			k = 0
			line_number += 1
			y = y_offset + line_number * box_size
			for i, (c, r) in enumerate(zip(no_bulge_offtarget_sequence, target_seq)):
				x = x_offset + k * box_size
				if r == '-':
					if 0 < k < len(target_seq):
						x = x_offset + (k - 0.25) * box_size
						dwg.add(dwg.rect((x, box_size * 1.4 + y), (box_size*0.6, box_size*0.6), fill=colors[c]))
						dwg.add(dwg.text(c, insert=(x+1, 2 * box_size + y - 2), fill='black', style="font-size:10px; font-family:Courier"))
				elif c == r:
					dwg.add(dwg.text(u"\u2022", insert=(x + 4.5, 2 * box_size + y - 4), fill='black', style="font-size:10px; font-family:Courier"))
					k += 1
				elif r == 'N':
					dwg.add(dwg.text(c, insert=(x + 3, 2 * box_size + y - 3), fill='black', style="font-size:15px; font-family:Courier"))
					k += 1
				else:
					dwg.add(dwg.rect((x, box_size + y), (box_size, box_size), fill=colors[c]))
					dwg.add(dwg.text(c, insert=(x + 3, 2 * box_size + y - 3), fill='black', style="font-size:15px; font-family:Courier"))
					k += 1
		if bulge_offtarget_sequence != '':
			k = 0
			line_number += 1
			y = y_offset + line_number * box_size
			for i, (c, r) in enumerate(zip(bulge_offtarget_sequence, realigned_target_seq)):
				x = x_offset + k * box_size
				if r == '-':
					if 0 < k < len(realigned_target_seq):
						x = x_offset + (k - 0.25) * box_size
						dwg.add(dwg.rect((x, box_size * 1.4 + y), (box_size*0.6, box_size*0.6), fill=colors[c]))
						dwg.add(dwg.text(c, insert=(x+1, 2 * box_size + y - 2), fill='black', style="font-size:10px; font-family:Courier"))
				elif c == r:
					dwg.add(dwg.text(u"\u2022", insert=(x + 4.5, 2 * box_size + y - 4), fill='black', style="font-size:10px; font-family:Courier"))
					k += 1
				elif r == 'N':
					dwg.add(dwg.text(c, insert=(x + 3, 2 * box_size + y - 3), fill='black', style="font-size:15px; font-family:Courier"))
					k += 1
				else:
					dwg.add(dwg.rect((x, box_size + y), (box_size, box_size), fill=colors[c]))
					dwg.add(dwg.text(c, insert=(x + 3, 2 * box_size + y - 3), fill='black', style="font-size:15px; font-family:Courier"))
					k += 1

		if no_bulge_offtarget_sequence == '' or bulge_offtarget_sequence == '':
			reads_text = dwg.text(str(round(seq['reads'],2)), insert=(box_size * (len(target_seq) + 1) + 20, y_offset + box_size * (line_number + 2) - 2),
								  fill='black', style="font-size:15px; font-family:Courier")
			position_text = dwg.text(str(seq['position']), insert=(box_size * (len(target_seq) + 1) + 84, y_offset + box_size * (line_number + 2) - 2),
								  fill='black', style="font-size:15px; font-family:Courier")
			overhang_text = dwg.text(str(seq['overhang']), insert=(box_size * (len(target_seq) + 1) + 254, y_offset + box_size * (line_number + 2) - 2),
								  fill='black', style="font-size:15px; font-family:Courier")
			dwg.add(reads_text)
			dwg.add(position_text)
			dwg.add(overhang_text)
		else:
			reads_text = dwg.text(str(round(seq['reads'],2)), insert=(box_size * (len(target_seq) + 1) + 20, y_offset + box_size * (line_number + 1) + 5),
								  fill='black', style="font-size:15px; font-family:Courier")
			position_text = dwg.text(str(seq['position']), insert=(box_size * (len(target_seq) + 1) + 84, y_offset + box_size * (line_number + 2) - 2),
								  fill='black', style="font-size:15px; font-family:Courier")
			overhang_text = dwg.text(str(seq['overhang']), insert=(box_size * (len(target_seq) + 1) + 254, y_offset + box_size * (line_number + 2) - 2),
								  fill='black', style="font-size:15px; font-family:Courier")
			dwg.add(reads_text)
			dwg.add(position_text)
			dwg.add(overhang_text)
			reads_text02 = dwg.text(u"\u007D", insert=(box_size * (len(target_seq) + 1) + 7, y_offset + box_size * (line_number + 1) + 5),
								  fill='black', style="font-size:23px; font-family:Courier")
			dwg.add(reads_text02)
	dwg.save()

def main():
	parser = argparse.ArgumentParser(description='Plot visualization plots for re-aligned reads.')
	parser.add_argument("--identified_file", help="FullPath/output file from reAlignment_circleseq.py", required=True)
	parser.add_argument("--title", help="Plot title", required=True)
	parser.add_argument("--target", help="Target sequence", required=True)
	args = parser.parse_args()

	print(args)

	visualizeOfftargets(args.identified_file, args.identified_file.strip(".tsv$"), args.title, args.target)

if __name__ == "__main__":

	main()
