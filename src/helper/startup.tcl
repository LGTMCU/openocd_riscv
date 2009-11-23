# Defines basic Tcl procs that must exist for OpenOCD scripts to work.
#
# Embedded into OpenOCD executable
#


# We need to explicitly redirect this to the OpenOCD command
# as Tcl defines the exit proc
proc exit {} {
	ocd_throw exit
}

# Help text list. A list of command + help text pairs.
proc cmd_help {cmdname h indent} {
	set indent [expr $indent * 2]

	set fmt_str [format "%%%ds%%-%ds %%s" $indent [expr 25 - $indent]]
	set w [expr 50 - $indent]
	set n 0

	while 1 {
		if {$n > [string length $h]} {break}

		set next_a [expr $n + $w]
		if {[string length $h] > $n + $w} \
		{
			set xxxx [string range $h $n [expr $n + $w]]
			for {set lastpos [expr [string length $xxxx] - 1]} \
				{$lastpos >= 0 && [string compare \
					[string range $xxxx $lastpos $lastpos] " "] != 0} \
				{set lastpos [expr $lastpos - 1]} \
			{
			}
			#set next_a -1
			if {$lastpos != -1} {
				set next_a [expr $lastpos + $n + 1]
			}
		}

		puts [format $fmt_str "" $cmdname \
				[string range $h $n [expr $next_a - 1]] ]
		set cmdname ""
		set n [expr $next_a]
	}
}

# Try flipping / and \ to find file if the filename does not
# match the precise spelling
proc find {filename} {
	if {[catch {ocd_find $filename} t]==0} {
		return $t
	}
	if {[catch {ocd_find [string map {\ /} $filename} t]==0} {
		return $t
	}
	if {[catch {ocd_find [string map {/ \\} $filename} t]==0} {
		return $t
	}
	# make sure error message matches original input string
	return -code error "Can't find $filename"
}
add_usage_text find "<file>"
add_help_text find "print full path to file according to OpenOCD search rules"

# Run script
proc script {filename} {
	source [find $filename]
}
add_help_text script "filename of OpenOCD script (tcl) to run"
add_usage_text script "<file>"

#########

# catch any exceptions, capture output and return output
proc capture_catch {a} {
	catch {
		capture {uplevel $a}
	} result
	return $result
}
