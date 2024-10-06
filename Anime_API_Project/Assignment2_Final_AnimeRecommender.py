#This assignment is about API's
#I will be using api.jikan.moe/v4 API to suggest you some anime based on a genre of your choice!
"""
Features:
1. Asks the user what genre of anime they are looking for -- Done
2. There are multiple pages in the API
    - The programme uses a random number generator to decide which pages it will search (2 pages - 50 anime choices) -- Done
2. Outputs a maximum of 5 out of the 50 anime that are well rated (score > 6). -- Done
3. Allows the user to read a synopsis of the anime they choose -- Done
4. Allows the user to add anime to a watch-list if they wish -- Done
    - The watch list is printed out in the format:
      Anime Title (Release Year) - Genre - *score*
"""

# Necessary imports
import requests
from pprint import pprint as pp
import random

# This function gets the genre requested by the user
def genre():
    endpoint = "https://api.jikan.moe/v4/genres/anime"
    response = requests.get(endpoint)

    if response.status_code != 200:
        print("Sorry, the data could not be retrieved.")

    elif response.status_code == 200:
        data = response.json()
        print("Genre Options: ")
        genre_list = [genre['name'] for genre in data['data']]
        pp(genre_list)

        # used title and strip to handle different input errors
        user_genre = input("Pick a genre: ").title().strip()
        print(user_genre)

        #code for what happens when you enter an invalid input
        #and an option to exit if you want
        while user_genre not in genre_list:
            print(f"""This is not a valid genre.
            Please pick something else from this list or type "Exit".:
            {pp(genre_list)}""")
            user_genre = input("Pick a genre: ").title().strip()
            print(user_genre)
            if user_genre == "Exit":
                print("Thank you for using Srishty's Anime Finder")
                exit()

        # need to return the ID of the chosen genre:
        genre_list_index = genre_list.index(user_genre)
        genre_id = data['data'][genre_list_index]['mal_id']

        #print(genre_id)
        return genre_id, user_genre

#This functions searches 2 random pages from the API and returns 5 anime that has a good score from the genre you picked
def top_5_anime(genre_id, user_genre):
    endpoint = f"https://api.jikan.moe/v4/anime?genres={genre_id}&page=1"
    response = requests.get(endpoint)
    if response.status_code != 200:
        print("Sorry, the data could not be retrieved.")

    elif response.status_code == 200:
        data = response.json()
        #Choosing 2 random pages to search
        pages_searched = 2
        no_pages = data['pagination']['last_visible_page']
        random_pages_list = []
        #If there are only 2 or less pages the code just takes all the pages available
        if no_pages <= pages_searched:
            for i in range(1, no_pages):
                random_pages_list.append(no_pages)
        #Otherwise 2 random pages are chosen - care taken to avoid duplicate pages
        else:
            while len(random_pages_list) < pages_searched :
                random_no = random.randint(1, no_pages)
                if random_no not in random_pages_list:
                    random_pages_list.append(random_no)

        #empty list data structure to store information needed
        #ga stands for good anime.
        ga_titles = []
        ga_synopsis = []
        ga_score = []
        ga_release_year = []

        #loop through the 2 pages
        for page in random_pages_list:
            endpoint = f"https://api.jikan.moe/v4/anime?genres={genre_id}&page={page}"
            response = requests.get(endpoint)
            data = response.json()
            anime_list = data['data']

            #logic for choosing the animes
            for anime in anime_list:
                if anime['score'] is not None: #ignores anime's that don't have a score
                    if anime['score'] >= 6  and len(ga_titles) < 5:
                        ga_titles.append(anime['title'])
                        ga_synopsis.append(anime['synopsis'])
                        ga_score.append(anime['score'])
                        ga_release_year.append(anime['aired']['from'][0:4]) #using string slicing to extract the year

        #printing the recommendations
        print("Here are some anime recommendations: ")
        number = 1
        for title in ga_titles:
            print(f"{number}. {title} \n")
            number += 1

        #asking user if they want to read the synopsis
        user_interested = input("Would you like to know more about one of these anime's (y/n): ")

        while user_interested == "y":
            number = int(input("Which anime would you like to know more about? \n Pick a number: "))
            while number not in range(1, 6):
                number = int(input("Please enter a number from 1 - 5."))

            user_interested_index  = number - 1
            pp(ga_synopsis[user_interested_index])

            user_interested = input("Would you like to know more about another one of these anime's (y/n): ")

        #asking the user if they want to add any of the anime to a watchlist
        user_add_watchlist_yn = input("Would you like to add any of the anime to your watchlist? (y/n) ")

        if user_add_watchlist_yn == 'n':
            print("Thank you for using this anime finder programme! ʕ •ᴥ•ʔ")

        #writing anime to a file
        elif user_add_watchlist_yn == 'y':
            add_anime = input("Plase insert the numbers of the recommendations you want to add in the format- \
'1,2,5' - if you wish to add the first second and fifth anime:").strip().replace(",","")
            add_anime_list = list(add_anime)

            with open("Watch_List.txt", "a+") as file:
                for i in add_anime_list:
                    index = int(i) - 1
                    text = f"""{ga_titles[index]} ({ga_release_year[index]}) - {user_genre} - *{ga_score[index]}*
-------------------------------------------------------------------------------------------------------------\n"""
                    file.write(text)
            print("Your recommendations have been added to Watch_List.txt:")
            print("~~Thank you for using this anime finder programme! (ᗒ‿ᗕ)")

        return ga_titles

run_genre = genre()
top_5_anime(run_genre[0], run_genre[1])
