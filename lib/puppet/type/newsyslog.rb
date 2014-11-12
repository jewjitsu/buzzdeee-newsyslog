Puppet::Type.newtype(:newsyslog) do
	@doc = "Manage the contents of /etc/newsyslog.conf"

	ensurable

	newparam(:name) do
		desc "The log file to rotate"

		isnamevar
	end

	newproperty(:owner) do
		desc "Optional owner (user) of log file"
	end

	newproperty(:group) do
		desc "Optional group of log file"
	end

	newproperty(:mode) do
		desc "File mode (permissions) of log file"
	end

	newproperty(:keep) do
		desc "Number of archive log files to keep"
	end

	newproperty(:size) do
		desc "Size of log file"
	end

	newproperty(:when) do
		desc "Frequency of rotation"
	end

	newproperty(:flags) do
		desc "Newsyslog rotation flags. See newsyslog docs for meaning"
	end

	newproperty(:pidfile) do
		desc "Optional Path to file with process ID"
	end

	newproperty(:sigtype) do
		desc "Optional signal type for process. Numeric or symbolic"
	end
end
