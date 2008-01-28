# This is a basic gawk backend for bashdoc(1)
# (c) 2007 Andrés J. Díaz <ajdiaz@connectical.net>
# --
# This file is part of bashdoc project.

# At the beggining set the flag last_comment to 0, this flag is used to
# detect when a code block starts (or a comment block ends).
BEGIN { last_comment=0; }

# We ignore lines which starts by a comment followed by exclamation mark or
# minus sign.
/^[#]!/ { next }
/^[#]-/ { next }

# Code block parser. We consider a code block everthing which are not
# a comment block. We print the :: mark (starts a pre-formated block in RST)
# only at the beggining of code block.
/^[:space:]*[^#\n].*/ {
	if (last_comment == 1)
		printf "\n\n::\n\n"
	last_comment=0
	print "  "$0
}

# The following rules create a RST notes for each codification label, such
# as TODO, FIXME and XXX.
/^[#][ ]*TODO.*/ {
	print "\n.. note:: To-Do"
	sub("^[#][ ]*TODO[:]?","")
	print "  "$0
}
/^[#][ ]*FIXME.*/ {
	print "\n.. note:: Fix me"
	sub("^[#][ ]*FIXME[:]?","")
	print "  "$0
}
/^[#][ ]*XXX.*/ {
	print "\n.. note:: Hack"
	sub("^[#][ ]*XXX[:]?","")
	print "  "$0
}

# Comment block parser. A comment block is a number of lines starting by
# a sharp symbol (#). We also accept lines in advanced bsah guide format,
# such as #+ and #>. Some text are parser specially, for example the
# copyright line in emphatized, and both, copyright and registered symbols
# are substituted.
/^[#].*/ {
	last_comment=1
	sub("^[:space:]*#[+> ]*","")
	sub("^[Cc]opyright.*","*&*")
	sub("\\([cC]\\)","©")
	sub("\\([rR]\\)","®")
	printf "\n%s",$0
}

# Finally print the EOL (we do not put the EOL when parsing comment block.
END { printf "\n" }