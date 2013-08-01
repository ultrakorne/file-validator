#!/usr/bin/env python
'''Generates a fingerprint plist containing signatures for each file found in ./sign_these'''

import sys,commands,hashlib,os,string,random,plistlib

def print_doc_and_exit():
  doc = 'Generates a fingerprint plist containing signatures for each file found in ./sign_these .\nUsage:\n./signer.py [32 char long secret]'
  print doc
  sys.exit(1)
  return

def main():
  the_secret = ""
  charlist = string.digits + string.letters

  if len(sys.argv) < 2:
    the_secret = "".join([random.choice(charlist) for x in range(32)])
  else:
    the_secret = sys.argv[1]

  if len(the_secret) != 32:
    print "[ERROR]: Length of secret is not 32 !\n\n"
    print_doc_and_exit()

  primes = [ 2  ,  3  ,  5  ,  7  ,  11  ,  13  ,  17  ,  19  ,  23  ,  29  ,  31  ,  37  ,  41  ,  43  ,  47  ,  53  ,  59  ,  61  ,  67  ,  71  ,  73  ,  79  ,  83  ,  89  ,  97  ,  101  ,  103  ,  107  ,  109  ,  113  ,  127  ,  131  ,  137  ,  139  ,  149  ,  151  ,  157  ,  163  ,  167  ,  173  ,  179  ,  181  ,  191  ,  193  ,  197  ,  199  ,  211  ,  223  ,  227  ,  229  ,  233  ,  239  ,  241  ,  251  ,  257  ,  263  ,  269  ,  271  ,  277  ,  281  ,  283  ,  293  ,  307  ,  311 ]


  obfuscated = [random.choice(charlist) for x in range(300)]

  j = 0

  for i in range(310):
    if i in primes:
      obfuscated[i] = the_secret[j]
      j += 1
      if j >= len(the_secret):
        break

  obfuscated_secret = "".join(obfuscated)


  signature_dict = {}
  total_files = 0

  for f in os.listdir("sign_these"):
    fn = os.path.join("sign_these", f)
    fhandle  = open(fn, "rb")
    m = hashlib.sha256()
    m.update(fhandle.read())
    m.update(the_secret)
    signature = m.hexdigest()
    fhandle.close()
    signature_dict[f] = signature
    total_files += 1


  plistlib.writePlist( signature_dict, "fingerprints.plist" )
  print "Generated fingerprints.plist with %d signatures from ./sign_these"%total_files
  print("Obfuscated secret = %s"%obfuscated_secret)
  print("Actual secret = %s"%the_secret)

  
main()
