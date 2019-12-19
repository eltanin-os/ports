BEGIN {
	flag=1
}

# OUTPUT RULES
/%IFBLK/ {
	if (ENVIRON[$2] == "true") {
		flag=1
		next
	} else flag=0
}

/%IF/ {
	if (ENVIRON[$2] == "true") sub(".*"$2, "")
	else next
}

/%END/ {
	flag=1
	next
}

# REPLACE RULES
/%.*%/ {
	r=$0
	s=index(r, "%")
	if (s && substr(r, s + 1, 1) != "%") do {
		d=substr(r, s+1)
		n=index(d, "%") - 1
		t=sprintf("%.*s", n, d)
		# VAL
		v=ENVIRON[t]
		r=sprintf("%.*s%s%s", s - 1, r, v, substr(r, s + n + 2))
	} while (s=index(r, "%"))
	$0=r
}

/%%.*%%/ {
	idx=match($0, "%%.*%%")
	x=""
	for (i = 1; i < idx; i++) x= x "\t"
	gsub(/%/, "", $1)
	v= x ENVIRON[$1]
	gsub(/;*$/, "", v)
	gsub(/;EOF/, "\nEOF", v)
	gsub(/; |;/, "\n" x, v)
	$0=v
}

flag
