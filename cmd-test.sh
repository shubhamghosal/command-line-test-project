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

function cmdtest () {
    echo "---------------------"
    echo "     Welcome         "
    echo "---------------------"

    echo "1. Sign Up"
    echo "2. Sign In"
    echo "3. Exit"

    read -p "Enter your choice: " choice

    if [ ! -f "user.csv" ]
    then
        touch user.csv
    fi

    if [ ! -f "password.csv" ]
    then
        touch password.csv
    fi

    case $choice in
        1)
            read -p "Enter the username: " user

            unames=(`cat user.csv`)
            unames_len=${#unames[@]}
            flag=1
            for i in `seq 0 $(($unames_len-1))`
            do
                if [ $user = ${unames[$i]} ]
                then
                    flag=0
                fi
            done

            if [ $flag -eq 1 ]
            then
                echo $user >> user.csv
                echo "Enter your password: "
                read -s pass1
                echo "Confirm your password: "
                read -s pass2

                if [ $pass1 = $pass2 ]
                then
                    echo $pass2 | base64 >> password.csv
                    echo "User registration succesfull!!!"
                else
                    echo "Password mismatch! Please enter correct password"
                fi

            else
                echo "The $user username is already present"
                cmdtest
            fi
            ;;
        2) 
            read -p "Enter the username: " user

            uname=(`cat user.csv`)
            uname_len=${#uname[@]}
            pass=(`cat password.csv`)
            index=""
            for i in `seq 0 $(($uname_len-1))`
            do
                if [ "$user" = "${uname[$i]}" ]
                then
                    index=$i
                fi
            done
            if [ -n "$index" ]
            then
                echo "Username Matched!!!"
                echo "Enter your password: "
                read -s pass1

                if [ $pass1 = `echo ${pass[$index]} | base64 --decode` ]
                then
                    echo "Password Matched."
                    echo "Signed in successfully!!!"
                    echo "-----Hello $user!-------"
                    echo "1. Take Test"
                    echo "2. Exit / Logout"
                    read -p "Choose your option: " opt

                    case $opt in 
                        1)
                            qbank_lines=`cat questionbank.txt | wc -l`
                            for i in `seq 5 5 $qbank_lines`
                            do
                                cat questionbank.txt | head -$i | tail -5
                                for j in `seq 10 -1 1`
                                do
                                    echo -e "\r Enter the choice :$j \c"
                                    read -t 1 option

                                    if [ -z "$option" ]
                                    then
                                        option="e"
                                    else
                                        break
                                    fi
                                done
                                echo $option >> user_answer.txt
                                echo "-------------------------"
                            done          
                            user_ans=(`cat user_answer.txt`)
                            crrt_ans=(`cat correctanswer.txt`)
                            uans_len=${#user_ans[@]}
                            count=0
                            for i in `seq 0 $(($uans_len-1))`
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
                            result=(`cat result.txt`)
                            for i in `seq 5 5 $qbank_lines`
                            do
                                cat questionbank.txt | head -$i | tail -5
                                if [ ${result[$k]} = "correct" ]
                                then
                                    echo -e "\e[32mCorrect Answer!"
                                    echo "Option Selected: ${user_ans[`echo "$i / 5 - 1" | bc`]}"
                                elif [ ${result[$k]} = "wrong" ]
                                then
                                    echo -e "\e[31mWrong Answer!"
                                    echo -n "Option Selected: ${user_ans[`echo "$i / 5 - 1" | bc`]}, "
                                    echo "Correct Option: ${crrt_ans[`echo "$i / 5 - 1" | bc`]}"
                                else
                                    echo -e "\e[33mTimeout!"
                                fi
                                k=$(($k+1))
                                echo -e "\e[0m------------------"
                            done
                            echo "Total Correct Answers: $count out of $uans_len"
                            rm user_answer.txt
                            rm result.txt
                            ;;
                        2)
                            echo "You are logged out!!!"
                            cmdtest
                            ;;                                
                    esac
                else
                    echo "Incorrect Password! Please enter the correct password."
                    cmdtest
                fi
            else
                echo "Incorrect Username! Please enter correct username"
                cmdtest
            fi
            ;;
        3)
            echo "Goodbye! Have a nice day"
            ;;
    esac
}

cmdtest
