# Assembly-Language-UI-with-Reverse-Engineering

A. Assembly Code:

In the given program a user interface is built using assembly language 16 bit code. It asked for user id &amp; password, if its correct then it will ask for user information which is stored in a file with encrypted password.

The output of the above class is as shown as below: (as code is of 16 bit dosbox is preferred to run)

1. Enter user ID:

![image](https://user-images.githubusercontent.com/37010825/125784338-fafd95ce-d9aa-4bb5-884b-837804d501cd.png)

2. Enter Password:(Password is hidden)

![image](https://user-images.githubusercontent.com/37010825/125784431-b8c34a44-e01e-4c56-a94d-bef789562b46.png)

3. Enter user information:

![image](https://user-images.githubusercontent.com/37010825/125784653-2cfb0d6a-5c3b-4d80-9fb8-027c5270385f.png)

4. The output is stored in the txt file as follows:

Ronak Code
16/03/1998
123456789
tpqt

-> where tpqt is encrypted password.

B. Reverse Engineering EXE file of the given assembly code using IDA Pro:

1. After reverse engineering the id and password is bypass with any of the key enter and the encryption of the password is bypass and stored with original password and even at below of the text file a warning msg is displayed.

2. After using IDA Pro, the exe file would run as following images:

![image](https://user-images.githubusercontent.com/37010825/125785725-682c08aa-ba52-4e93-ae2d-c709718adee3.png)

The txt file output is:

Ronak Code
16/03/1998
root
Your information has been leaked!
