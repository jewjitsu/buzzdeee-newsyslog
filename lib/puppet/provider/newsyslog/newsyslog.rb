require 'puppet/provider/parsedfile'

newsyslog = '/etc/newsyslog.conf'
 
Puppet::Type.type(:newsyslog).provide(
	:parsed,
	:parent => Puppet::Provider::ParsedFile,
	:default_target => newsyslog,
	:filetype => :flat) do

	# confine :exists => newsyslog
 
	desc "The newsyslog provider that uses the ParsedFile class"
 
	text_line :comment, :match => /^#/;
	text_line :blank, :match => /^\s*$/;
 
	record_line :parsed,
		# TODO: usergroup parsing
		:fields => %w{name usergroup mode keep size when flags remainder},
		:match  => %r{^\s*(/\S+)\s+(\w*:\w*|)\s+(\d\d\d)\s+(\d+)\s+(\d+|\*)\s+(\S+)\s*([BFMZ]*)\s*(.*)},
		:optional => %w{usergroup flags remainder},
		:post_parse => proc { |hash|
			if hash[:usergroup] == :absent
				# no user/group
				hash[:owner] = :absent
				hash[:group] = :absent
			else
				# split user/group into properties
				ugarr = hash[:usergroup].split(':')
				hash[:owner] = ugarr[0]
				hash[:group] = ugarr[1]

				# XXX: oddly, if one gets the string 'absent' it evaluates
				#      to :absent somehow - throwing an actual 'absent'
				#      parameter off. Don't know of a way around this.

				hash[:owner] = :absent if hash[:owner] == nil
				hash[:group] = :absent if hash[:group] == nil
				hash[:owner] = :absent if hash[:owner] == ''
				hash[:group] = :absent if hash[:group] == ''
			end
			# remove the actual usergroup property, is a pseudo string
			hash.delete(:usergroup)
		},
		:pre_gen => proc { |hash|
			if (hash.has_key? :owner and hash[:owner] != nil and hash[:owner] != :absent) or (hash.has_key? :group and hash[:group] != nil and hash[:group] != :absent)
				# either user or group exists, generate a field for it
				hash[:owner] = '' if hash[:owner] == :absent
				hash[:group] = '' if hash[:group] == :absent
				hash[:usergroup] = "#{hash[:owner]}:#{hash[:group]}"
			end
			hash[:remainder] = '' if (hash[:remainder] == :absent or hash[:remainder] == nil)
			if (hash.has_key? :monitor)
				if (hash.has_key? :flags and hash[:flags].match(/M/))
					hash[:remainder] = "#{hash[:monitor]}"
				else
					raise Puppet::ParseError, "Monitor mail receiver must be specified in combination with M flag in flags field."
				end
			end
			if (hash.has_key? :command and (hash.has_key? :pidfile or hash.has_key? :sigtype))
				raise Puppet::ParseError, "Given command parameter and pidfile or sigtype. Parameter command is mutually exclusive to the others."
			end
			if ((hash.has_key? :pidfile and not hash.has_key? :sigtype) or (hash.has_key? :sigtype and not hash.has_key? :pidfile))
				raise Puppet::ParseError, "Parameters pidfile and sigtype must be specified together."
			end
			if (hash.has_key? :command)
				hash[:remainder] << " \"#{hash[:command]}\""
			end
			if (hash.has_key? :pidfile)
				hash[:remainder] << " #{hash[:pidfile]} #{hash[:sigtype]}"
			end
		}
end
