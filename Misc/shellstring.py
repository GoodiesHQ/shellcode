#!/usr/bin/env python2
import sys, binascii
def foo(s, bits):
	if bits == 32:
		if len(s) == 2:
			print "\tmov dl, 0x%s" % s
		if len(s) == 4:
			print "\tmov dx, 0x%s" % s
		if len(s) == 6:
			print "\tmov dh, 0x%s\n\tshl edx, 8\n\tmov dx, 0x%s" % (s[:2], s[2:])
		print "\tpush edx"
	if bits == 64:
		if len(s) == 2:
			print "\tmov r8b, 0x%s" % s
		if len(s) == 4:
			print "\tmov r8w, 0x%s" % s
		if len(s) == 6:
			print "\tmov r8b, 0x%s\n\tshl r8, 16\n\tmov r9w, 0x%s\n\tor r8, r9" % (s[:2], s[2:])
		if len(s) == 8:
			print "\tmov r8d, 0x%s" % s
		if len(s) == 10:
			print "\tmov r8b, 0x%s\n\tshl r8, 32\n\tmov r9d, 0x%s\n\tor r8, r9" % (s[:2], s[2:])
		if len(s) == 12:
			print "\tmov r8w, 0x%s\n\tshl r8, 32\n\tmov r9d, 0x%s\n\tor r8, r9" % (s[:4], s[4:])
		if len(s) == 14:
			print "\tmov r8b, 0x%s\n\tshl r8, 16\n\tmov r9w, 0x%s\n\tor r8, r9\n\tshl r8, 32\n\tshr r9, 16\n\tmov r9d, 0x%s\n\tor r8, r9" % (s[:2], s[2:6], s[6:])
		print "\tpush r8"

def main():
	if len(sys.argv) > 1:
		bits = 32
		if len (sys.argv) > 2:
			arch = sys.argv[2]
			if arch in ['x86', '32', 'i386']:
				bits = 32
			elif arch in ['x64', '64']:
				bits = 64
			else:
				print "Defaulting to 32-bit NASM"
		mod = bits/4
		s	= binascii.hexlify(sys.argv[1].decode("string_escape"))
		s	= ''.join(reversed([s[i:i+2] for i in range(0, len(s), 2)]))
		size	= len(s)/2
		if bits == 32:
			print "\txor edx, edx"
		elif bits == 64:
			print "\txor r8, r8"
		tmp = len(s) % mod
		if tmp != 0:
			if bits == 64:
				print "\txor r9, r9"
			a,s = s[:tmp], s[tmp:]
			foo(a, bits)
		else:
			if bits == 32:
				print "\tpush edx"
			elif bits == 64:
				print "\tpush r8"
		for i in range(0, len(s), mod):
			if bits == 32:
				print "\tpush 0x%s" % s[i:i+mod]
			if bits == 64:
				print "\tmov r8, 0x%s\n\tpush r8" % s[i:i+mod]
		print "\nSize: %i (0x%s)" % (size, hex(size))
	else:
		print('Usage:\n\t%s "String To Reverse" [32/64]' % sys.argv[0])

if __name__=="__main__":
	main()