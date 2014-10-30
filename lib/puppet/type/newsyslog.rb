Puppet::Type.newtype(:newsyslog) do
	@doc = "Manage the contents of /etc/newsyslog.conf"

	ensurable

	newparam(:name) do
		desc "The log file to rotate"

		isnamevar
	end

	newproperty(:ownergroup) do
		desc "Optional owner:group of the log file, either owner or group can be empty"
	end

	newproperty(:mode) do
		desc "File mode (permissions) in octal of log file"
	end

	newproperty(:keep) do
		desc "Number of archived log files to keep"
	end

	newproperty(:size) do
		desc "Minimum size of log file, if the file is larger it will get rotated"
	end

	newproperty(:when) do
		desc "Frequency of rotation"
	end

	newproperty(:flags) do
		desc "Newsyslog rotation flags. See newsyslog docs for meaning"
	end

	newproperty(:pidfile) do
		desc "Optional Path to file with process ID. This is exclusive with the command"
	end

	newproperty(:sigtype) do
		desc "Optional signal type for process. Must be a symbolic name, i.e. SIGUSR1. This is only valid in combination with pidfile"
	end

	newproperty(:command) do
		desc "Optional command to run instead of sending a signal to a process. This is exclusive with the pidfile"
	end
end
