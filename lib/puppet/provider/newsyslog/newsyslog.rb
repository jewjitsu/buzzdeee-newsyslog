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
		:fields => %w{name usergroup mode keep size when flags pidfile sigtype},
		:optional => %w{usergroup pidfile sigtype},
		:post_parse => proc { |hash|
			if hash[:usergroup].include? ':'
				# found user/group, keep field ordering

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
			else
				# no user/group, shift field ordering
				hash[:sigtype] = hash[:pidfile] if hash.has_key? :pidfile
				hash[:pidfile] = hash[:flags] if hash.has_key? :flags
				hash[:flags] = hash[:when] if hash.has_key? :when
				hash[:when] = hash[:size] if hash.has_key? :size
				hash[:size] = hash[:keep] if hash.has_key? :keep
				hash[:keep] = hash[:mode] if hash.has_key? :mode
				hash[:mode] = hash[:usergroup] if hash.has_key? :usergroup

				hash[:owner] = :absent
				hash[:group] = :absent
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

			# TODO: If 'size' or 'when' are incompatibly set then need to raise
			#       some errors.

		}
end
