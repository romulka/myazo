#!/usr/bin/env ruby

# setting
browser_cmd = '/opt/google/chrome/chrome'
clipboard_cmd = 'xclip'
proxy_addr = nil
proxy_port = nil

require 'net/http'

# get id
idfile = ENV['HOME'] + "/.gyazo.id"

id = ''
if File.exist?(idfile) then
  id = File.read(idfile).chomp
end

# capture png file
tmpfile = "/tmp/image_upload#{$$}.png"
imagefile = ARGV[0]

if imagefile && File.exist?(imagefile) then
  system "convert #{imagefile} #{tmpfile}"
else
  system "import #{tmpfile}"
end

if !File.exist?(tmpfile) then
  exit
end

imagedata = File.read(tmpfile)
File.delete(tmpfile)

# upload
boundary = '----BOUNDARYBOUNDARY----'

HOST = '127.0.0.1'
CGI = '/post'
UA   = 'Gyazo/1.0'
PORT = 3000

data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
#{id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"; filename="newimg.png"\r
\r
#{imagedata}\r
--#{boundary}--\r
EOF

header ={
  'Content-Length' => data.length.to_s,
  'Content-type' => "multipart/form-data; boundary=#{boundary}",
  'User-Agent' => UA
}

Net::HTTP::Proxy(proxy_addr, proxy_port).start(HOST,PORT) {|http|
  res = http.post(CGI,data,header)
  url = res.response.body
  puts url
  if system "which #{clipboard_cmd} >/dev/null 2>&1" then
    system "echo -n #{url} | #{clipboard_cmd}"
  end
  system "#{browser_cmd} #{url}"

  # save id
  newid = res.response['X-Gyazo-Id']
  if newid and newid != "" then
    if !File.exist?(File.dirname(idfile)) then
      Dir.mkdir(File.dirname(idfile))
    end
    if File.exist?(idfile) then
      File.rename(idfile, idfile+Time.new.strftime("_%Y%m%d%H%M%S.bak"))
    end
    File.open(idfile,"w").print(newid)
  end
}
