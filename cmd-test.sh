#!/bin/bash

<<doc
Name: Shubham Ghosal
Date: 08/05/2022
Description: Project to implement command line test feature
Sample Input: ./cmd-test.sh
               1. Sign Up
               2. Sign In
               3. Exit
               Enter your choice: 3
Sample Output: Goodbye! Have a nice day
doc

# recursive function to implement login and test taking feature
function cmdtest () {
    echo "---------------------"
    echo "     Welcome         "
    echo "---------------------"

    echo "1. Sign Up"             # display menu to signup or login user
    echo "2. Sign In"
    echo "3. Exit"                # exit from the menu

    read -p "Enter your choice: " choice      # read choice from user

    if [ ! -f "user.csv" ]                    # check if user.csv file exists 
    then
        touch user.csv
    fi

    if [ ! -f "password.csv" ]                # check if password.csv file exists
    then
        touch password.csv
    fi

    case $choice in
        1)                                            # case statement if user selects signup option
            read -p "Enter the username: " user       # read username

            unames=(`cat user.csv`)                   # store all usernames from user file to array
            unames_len=${#unames[@]}
            flag=1
            for i in `seq 0 $(($unames_len-1))`       # loop to validate if entered username already exists or not
            do
                if [ $user = ${unames[$i]} ]
                then
                    flag=0
                fi
            done

            if [ $flag -eq 1 ]                        # if username does not exist request password from user
            then
                echo "Enter your password: "
                read -s pass1
                echo "Confirm your password: "        
                read -s pass2

                if [ $pass1 = $pass2 ]               # check for password confirmation
                then
                    echo $user >> user.csv                                    # save user to user.csv file
                    echo $pass2 | base64 >> password.csv                      # save encoded password in password.csv file
                    echo "User registration succesfull!!!"
                else
                    echo "Password mismatch! Please enter correct password"   # check for password mismatch & return to start menu
                    cmdtest
                fi

            else
                echo "The $user username is already present"                  # check if user is available & return to start menu
                cmdtest
            fi
            ;;
        2)                                                             # case option if user selects to sign in and proceed for the test
            read -p "Enter the username: " user                        # read the username

            uname=(`cat user.csv`)                                     # retrieve all username and store in array
            uname_len=${#uname[@]}
            pass=(`cat password.csv`)                                  # retrieve all password in encoded format and store in array
            index=""
            for i in `seq 0 $(($uname_len-1))`                         # loop to find if entered username is present in user.csv file                       
            do
                if [ "$user" = "${uname[$i]}" ]
                then
                    index=$i                                           # save index value of the username matched in file
                fi
            done
            if [ -n "$index" ]                                         # check if index variable is not null meaning user is present
            then
                echo "Username Matched!!!"
                echo "Enter your password: "
                read -s pass1                                               # read password from user

                if [ $pass1 = `echo ${pass[$index]} | base64 --decode` ]    # check if correct password is entered after decoding it from password.csv file
                then
                    echo "Password Matched."
                    echo "Signed in successfully!!!"
                    echo "-----Hello $user!-------"                         # print test taking menu after succesfull login
                    echo "1. Take Test"
                    echo "2. Exit / Logout"
                    read -p "Choose your option: " opt                      # choose the option to start test or logout

                    case $opt in 
                        1)                                                  # case option to start the test
                            qbank_lines=`cat questionbank.txt | wc -l`      # store number of lines in question bank file
                            for i in `seq 5 5 $qbank_lines`                 # loop to iterate through the question set each of five lines
                            do
                                cat questionbank.txt | head -$i | tail -5   # display the question
                                for j in `seq 10 -1 1`                      # loop to iterate 10 times in reverse
                                do
                                    echo -e "\r Enter the choice :$j \c"    # intializing 10 second counter for user to provide the option
                                    read -t 1 option

                                    if [ -z "$option" ]                     # check if no option is selection means timeout
                                    then
                                        option="e"
                                    else
                                        break                               # else break the inner loop
                                    fi
                                done
                                echo $option >> user_answer.txt             # store option in a temporary file
                                echo "-------------------------"
                            done          
                            user_ans=(`cat user_answer.txt`)                # store user selected option in an array
                            crrt_ans=(`cat correctanswer.txt`)              # store all the correct answers in an array
                            uans_len=${#user_ans[@]}
                            count=0
                            for i in `seq 0 $(($uans_len-1))`               # loop to check and compare the correct answers ans store in result.txt file
                            do
                                if [ ${user_ans[$i]} = ${crrt_ans[$i]} ]
                                then
                                    echo "correct" >> result.txt
                                    count=$(($count+1))
                                elif [ ${user_ans[$i]} = "e" ]
                                then
                                    echo "timeout" >> result.txt
                                else
                                    echo "wrong" >> result.txt
                                fi
                            done
                            echo "-----------------------------------"
                            echo "          Report Card              "
                            echo "-----------------------------------"
                            k=0
                            result=(`cat result.txt`)                      # store contents of result.txt file in an array
                            for i in `seq 5 5 $qbank_lines`                # loop to display the detailed report card to the user after exam
                            do
                                cat questionbank.txt | head -$i | tail -5
                                if [ ${result[$k]} = "correct" ]                                        # display if answer is correct in green
                                then
                                    echo -e "\e[32mCorrect Answer!"
                                    echo "Option Selected: ${user_ans[`echo "$i / 5 - 1" | bc`]}"
                                elif [ ${result[$k]} = "wrong" ]                                        # display if answer is wrong in red
                                then
                                    echo -e "\e[31mWrong Answer!"
                                    echo -n "Option Selected: ${user_ans[`echo "$i / 5 - 1" | bc`]}, "
                                    echo "Correct Option: ${crrt_ans[`echo "$i / 5 - 1" | bc`]}"
                                else
                                    echo -e "\e[33mTimeout!"                                            # display if timeout in yellow
                                fi
                                k=$(($k+1))
                                echo -e "\e[0m------------------"
                            done
                            echo "Total Correct Answers: $count out of $uans_len"                      # display total correct answers by user
                            rm user_answer.txt
                            rm result.txt
                            ;;
                        2)                                                             # case option if user selects to logout from test taking menu
                            echo "You are logged out!!!"
                            cmdtest
                            ;;                                
                    esac
                else
                    echo "Incorrect Password! Please enter the correct password."     # check if password given is incorrect then return back to main menu
                    cmdtest
                fi
            else
                echo "Incorrect Username! Please enter correct username"             # check if username is incorrect then return back to main menu
                cmdtest
            fi
            ;;
        3)                                                  # case option from main menu if user selects to make a final exit from it
            echo "Goodbye! Have a nice day"
            ;;
    esac
}

cmdtest                        # invoke a function call to the main menu
