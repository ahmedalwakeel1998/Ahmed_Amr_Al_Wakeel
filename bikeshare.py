import time
import pandas as pd
import numpy as np


CITY_DATA = { 'chicago': 'chicago.csv',
              'new york city': 'new_york_city.csv',
              'washington': 'washington.csv' }


def get_filters():
    """
    Asks user to specify a city, month, and day to analyze.

    Returns:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to apply no month filter
        (str) day - name of the day of week to filter by, or "all" to apply no day filter
    """
    print('Hello! Time to do that bikeshare project!')

    # get user input for city (chicago, new york city, washington)
    while True:
        city=input('Enter the city (Chicage, Washington, or New York City): ').lower()
        if city in CITY_DATA.keys():
            break
        print('Wrong Input! Please input a valid city or check your spelling :?')



    # get user input for month (all, january, february, ... , june)
    Months = ['All','January','February','March','April','May','June']
    while True:
        month=input('Enter the month, in full spelling please, or all for no filter by month (Data available up to June): ').title()
        if month in Months:
            break
        print('Wrong Input! Please input a valid month or check your spelling :?')

    # get user input for day of week (all, monday, tuesday, ... sunday)
    Days = ['All','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
    while True:
        day=input('Enter the day of the week, or all for no filter by day: ').title()
        if day in Days:
            break
        print('Wrong Input! Please input a valid day or check your spelling :?')


    print('-'*40)
    return city, month, day


def load_data(city, month, day):
    """
    Loads data for the specified city and filters by month and day if applicable.

    Args:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to apply no month filter
        (str) day - name of the day of week to filter by, or "all" to apply no day filter
    Returns:
        df - Pandas DataFrame containing city data filtered by month and day
    """

    # Generate and formats the dataframe so that it is usable
    df =  pd.read_csv(CITY_DATA[city])
    df['Start Time'] = pd.to_datetime(df['Start Time'])
    df['End Time'] = pd.to_datetime(df['End Time'])
    df['hour'] = df['Start Time'].dt.hour
    df['month'] = df['Start Time'].dt.month_name()
    df['day_of_week'] = df['Start Time'].dt.day_name()

    # Apply necessary filters if there are any
    if month != 'All':
        df = df[df['month'] == month]
    
    if day != 'All':
        df = df[df['day_of_week'] == day]

    return df


def time_stats(df,month,day):
    """
    Displays statistics on the most frequent times of travel only if there are no month or day filters. There will be 
    no useful output if the dataframe is already filtered by month or day.
    """

    print('\nCalculating The Most Frequent Times of Travel...')
    start_time = time.time()

    # display the most common month
    if month == 'All':
        popular_month=df['month'].mode()[0]
        print('\nThe most active month is {}.'.format(popular_month))

    # display the most common day of week
    if day == 'All':
        popular_day=df['day_of_week'].mode()[0]
        print('\nThe busiest day of the week is {}.'.format(popular_day))

    # display the most common start hour
    popular_hour=df['hour'].mode()[0]

    print('\nThe busiest start hour is {}!'.format(popular_hour))
    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def station_stats(df):
    """Displays statistics on the most popular stations and trip."""

    print('\nCalculating The Most Popular Stations and Trip...')
    start_time = time.time()

    # display most commonly used start station
    popular_startstation = df['Start Station'].mode()[0]

    # display most commonly used end station
    popular_endstation = df['End Station'].mode()[0]

    # display most frequent combination of start station and end station trip
    df['combination'] = df['Start Station'] + ' to ' + df['End Station']
    popular_combination = df['combination'].mode()[0]

    print('\nThe most used starting point is {}. The most used end point is {}.'.format(popular_startstation,popular_endstation))
    print('\nThe most frequent trip is from {}.'.format(popular_combination))
    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def trip_duration_stats(df):
    """Displays statistics on the total and average trip duration."""

    print('\nCalculating Trip Duration...')
    start_time = time.time()

    df['duration'] = df['End Time'] - df['Start Time']

    # display total travel time
    total_travel = df['duration'].sum()

    # display mean travel time
    average_travel = df['duration'].mean(skipna=True)

    print('\nTotal Travel Time is {}. The average trip time is {}.'.format(total_travel,average_travel))
    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def user_stats(df):
    """Displays statistics on bikeshare users."""

    print('\nCalculating User Stats...')
    start_time = time.time()
    try:
        # Display counts of user types
        user_types = df['User Type'].value_counts()
        print('\nThe data shows the split between subscriber and customer as \n{}.'.format(user_types))
    except:
        print('Cannot calculate user type statistics :(')
    
    try:
        # Display counts of gender
        gender = df['Gender'].value_counts()
        print('\nThe split between male and female is \n{}.'.format(gender))
    except:
        print('Cannot calculate gender statistics :(')

    try:
        # Display earliest, most recent, and most common year of birth
        earliest_DOB = int(df['Birth Year'].min())
        latest_DOB = int(df['Birth Year'].max())
        common_DOB = int(df['Birth Year'].mode()[0])
        print('\nThe oldest riders were born in {}. The youngest riders were born in {}.'.format(earliest_DOB,latest_DOB))
        print('The most common birth year is {}'.format(common_DOB))
    except:
        print('Cannot calculate birth year statistics :(')

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def main():
    while True:
        city, month, day = get_filters()
        df = load_data(city, month, day)

        time_stats(df,month,day)
        station_stats(df)
        trip_duration_stats(df)
        user_stats(df)

        raw_data = input('\nWould you like to see 5 rows of raw data? Enter yes or no.\n')
        if raw_data.lower() not in ['yes','no']:
                raw_data = input('\nPlease enter yes or no if full spelling: ')
        n=0
        pd.set_option('display.max_columns',200)
        df_default = pd.read_csv(CITY_DATA[city])

        while raw_data.lower() == 'yes':
            print(df_default.iloc[n:n+5])
            raw_data = input('\nWould you like to see 5 more rows of raw data? Enter yes or no.\n')
            if raw_data.lower() not in ['yes','no']:
                raw_data = input('\nPlease enter yes or no if full spelling: ')
            if raw_data.lower() == 'no':
                break
            n += 5
        

        restart = input('\nWould you like to restart? Enter yes or no.\n')
        if restart.lower() not in ['yes','no']:
                restart = input('\nPlease enter yes or no if full spelling: ')
        if restart.lower() != 'yes':
            break
    print('Hoooraayy, a good run, or I guess a good RIDE ;P')

        

if __name__ == "__main__":
	main()
