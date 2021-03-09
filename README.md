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

![](https://github.com/lb-githubtest/lukasbahrle-ios/blob/main/overview.png)

### Details

The app is separated en two main frameworks:

- ArtistBrowser: contains all the platform agnostic code
- lukasbahrle-ios: Composition of the app and UIKit specific code

Caching:

- The token is stored in the keychain
- The artist, albums and image responses are cached using the built in URLCache
