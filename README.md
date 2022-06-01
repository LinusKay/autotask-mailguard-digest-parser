# MailGuard Digest Parser

Scripts that allow for easy reading of MailGuard email quarantine digests. Will take an AutoTask ticket number and output tabular view of quarantined items, sorted by severity score. 

## Parse-MailGuardDigestAutoTask

Allows for easy viewing of MailGuard email quarantine summaries in a tabular format, sorted by severity score.

Output example:

```
Score Recipient                      Sender                                                                               Subject                                                         
----- ---------                      ------                                                                               -------                                                         
10.6  christiana@company.com.au      01010181098bc7da-c7bc4ff8-552b-4700-88b4-2d4761ccf085-000000@us-west-2.amazonses.com How is our local property market performing?                    
10.9  jason@company.com.au           office@affiliate18.affiliatepower.online                                             Top Survival Foods and Tips for your Stockpile                  
10.9  melissa@company.com.au         office@affiliate12.affiliatepower.online                                             Top Survival Foods and Tips for your Stockpile                  
11.6  info@company.com.au            help@live-supportmedia.ml                                                            Security Help Team                                              
12.8  jason@company.com.au           51872-90975-131959-13078-jason=company.com.au@mail.goldenformula.co                  The Big Deal About Tiny Mosquitoes                              
12.8  jason@company.com.au           51876-90975-131959-13188-jason=company.com.au@mail.textspeech.rest                   Clear Vision in 6-Seconds? Just Do THIS???                      
12.9  jason@company.com.au           51824-90975-131959-13185-jason=company.com.au@mail.flexonship.co                     Opening an email never felt so good                             
```
