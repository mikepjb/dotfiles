# In cases where you are given a file but do not know it's encoding, you can
# use this to attempt to convert from all possible encodings known to iconv,
# from there, you can try individual ones that came back okay and view them in
# vim to visually confirm that the characters have been correctly translated as
# intended.
#
# `iconv -f WINDOWS-1251 -t UTF-8 test.csv | vi -`
test_all_encodings() {
    iconv --list | sed 's/\/\/$//' | sort > encodings.list
    for a in `cat encodings.list`; do
        printf "$a  "
        iconv -f $a -t UTF-8 systeminfo.txt > /dev/null 2>&1 \
            && echo "ok: $a" || echo "fail: $a"
    done | tee result.txt
}
