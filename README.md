# Spotify artist browser

### Search artists

```Given the user has connectivity.  
  When the user enters a string in a search field.  
  Then the app should display a list matching artist depending on the entered search string.
```  
  

### Artist detail

```Given the user has connectivity
  When the user requests to see the details of an artist 
  Then the app should display the artist infomation and a list of the artist's albums
```

<br/>

## Use Cases

### Search Artist Use Case

#### Data
- access token
- search string

#### Primary course
1. Execute "Search Artist" command with above data
2. System loads data from remote service
3. System validates response data
4. System creates artists from valid data
5. System delivers artists

#### No connectivity – error course
1. System delivers `noConnectivity` error

#### Invalid token – error course
1. System executes "New Token" command to retrieve a new token
2. System validates response data
3. System retries "Search Artist" load

#### Invalid data – error course
1. System delivers `invalidData` error
   
<br/>
   
### Load Artist Albums Use Case

#### Data
- access token
- artist id

#### Primary course
1. Execute "Load Artist Albums" command with above data
2. System loads data from remote service
3. System validates response data
4. System creates albums from valid data
5. System delivers albums

#### No connectivity – error course
1. System delivers `noConnectivity` error

#### Invalid token – error course
1. System executes "New Token" command to retrieve a new token
2. System validates response data
3. System retries "Load Artist Albums"

#### Invalid data – error course
1. System delivers `invalidData` error
