let inputfile = "/var/log/httpd/access_log"

execute ":edit " . escape(inputfile, ' ')
let lastlineno = line("$")

let i = 0
let j = 0
let counter = 0
let attack_list = {}
let localhostv6 = "::1"
let localhostv4 = "127.0.0.1"

while i < lastlineno
  let i = i + 1
  let attacker  =  remove(split(getline(i)),0)
  if attacker !~? localhostv6 && attacker !~? localhostv4
    if has_key(attack_list, attacker) == 0
      let j = i
      while j < lastlineno
        if attacker ==? remove(split(getline(j)),0)
          let counter = counter + 1
        endif
        let j = j + 1
      endwhile
      let attack_list[attacker] = counter
      let counter = 0
    endif
  endif
endwhile


echo string(attack_list)
echo keys(attack_list)
let keys = keys(attack_list)
let i = 0
while i < len(keys)
    let k = keys[i]
    echo "key:" . k . ", value:" . attack_list[k]
    if attack_list[k] == "4"
      echo "key:". k . "over 4 access , We detected DoS Attack!!"
      "本当は、ここでconfigファイルを読んだバッファを編集したかったが難しかったので断念
      call system("perl -pi -e 's/\#EDoSDetected/\#EDoSDetected\n    Deny from ".k."/g' /etc/httpd/conf/httpd.conf")      
      call system("systemctl restart httpd.service")
    endif
    let i = i + 1
endwhile

bdelete
