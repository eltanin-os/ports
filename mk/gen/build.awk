BEGIN {
	flag=1
	if (length(rdeps) > 0) gsub(/ |^|$/, "'", rdeps)
	if (length(mdeps) > 0) gsub(/ |^|$/, "'", mdeps)
}

# PREPARE SECTIONS
{
	gsub(/;*$/, "", build)
	gsub(/;/, "\n\t\t", build)
	gsub(/;*$/, "", install)
	gsub(/;/, "\n\t\t\t", install)
	gsub(/;*$/, "", vars)
	gsub(/; /, "\n\t", vars)
}

# SECTIONS
{
	gsub(/%build%/, build)
	gsub(/%install%/, install)
	gsub(/%vars%/, vars)
}

# VARIABLES
{
	gsub(/%dbdir%/, dbdir)
	gsub(/%dev_dbdir%/, dev_dbdir)
	gsub(/%dev_syspath%/, dev_syspath)
	gsub(/%file%/, file)
	gsub(/%mirrors%/, mirrors)
	gsub(/%package%/, toupper(package))
	gsub(/%patches%/, patches)
	gsub(/%pkgdir%/, pkgdir)
	gsub(/%syspath%/, syspath)
}

# RULES
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

flag
