//# sourceURL=application.js

/*
 application.js
 Project10
 
 Copyright (c) 2017 Paul Hudson. All rights reserved.
*/

/*
 * This file provides an example skeletal stub for the server-side implementation 
 * of a TVML application.
 *
 * A javascript file such as this should be provided at the tvBootURL that is 
 * configured in the AppDelegate of the TVML application. Note that  the various 
 * javascript functions here are referenced by name in the AppDelegate. This skeletal 
 * implementation shows the basic entry points that you will want to handle 
 * application lifecycle events.
 */

/**
 * @description The onLaunch callback is invoked after the application JavaScript 
 * has been parsed into a JavaScript context. The handler is passed an object 
 * that contains options passed in for launch. These options are defined in the
 * swift or objective-c client code. Options can be used to communicate to
 * your JavaScript code that data and as well as state information, like if the 
 * the app is being launched in the background.
 *
 * The location attribute is automatically added to the object and represents 
 * the URL that was used to retrieve the application JavaScript.
 */


let genres = {};
let movies = {};

App.onLaunch = function(options) {
    this.baseURL = options.BASEURL;

    const loading = createActivityIndicator("Loading feed…")
    navigationDocument.pushDocument(loading);

    loadData("https://itunes.apple.com/us/rss/topmovies/limit=100/json", parseJSON)
}


App.onWillResignActive = function() {

}

App.onDidEnterBackground = function() {

}

App.onWillEnterForeground = function() {
    
}

App.onDidBecomeActive = function() {
    
}

App.onWillTerminate = function() {
    
}


function loadData(url, callback) {
    const request = new XMLHttpRequest();
    request.addEventListener("load", function() { callback(request.response); });
    request.open("GET", url);
    request.send();
}

function fixXML(str) {
    return str.replace("&", "&amp;");
}

function parseJSON(text) {
    const json = JSON.parse(text);

    for (entry of json["feed"]["entry"]) {
        let movie = {};
        movie.title = fixXML(entry["im:name"]["label"]);
        movie.genre = fixXML(entry["category"]["attributes"]["label"]);
        movie.summary = fixXML(entry["summary"]["label"]);
        movie.director = fixXML(entry["im:artist"]["label"]);
        movie.releaseDate = fixXML(entry["im:releaseDate"]["attributes"]["label"]);
        movie.price = fixXML(entry["im:price"]["label"]);
        movie.coverURL = fixXML(entry["im:image"][0]["label"]).replace("60x60", "600x600");
        movie.link = fixXML(entry["link"][0]["attributes"]["href"]);
        movie.trailerURL = fixXML(entry["link"][1]["attributes"]["href"]);

        if (movie.genre in genres) {
            genres[movie.genre].push(movie);
        } else {
            genres[movie.genre] = [movie];
        }

        movies[movie.trailerURL] = movie;
    }

    const shelfTitles = Object.keys(genres).sort();
    const stack = createStackTemplate(shelfTitles);
    navigationDocument.replaceDocument(stack, navigationDocument.documents[0]);

    stack.addEventListener("play", playSelectedMovie);
    stack.addEventListener("select", zoomSelectedMovie);
}

/**
 * This convenience funnction returns an alert template, which can be used to present errors to the user.
 */
var createAlert = function(title, description) {

    var alertString = `<?xml version="1.0" encoding="UTF-8" ?>
        <document>
          <alertTemplate>
            <title>${title}</title>
            <description>${description}</description>
          </alertTemplate>
        </document>`

    var parser = new DOMParser();

    var alertDoc = parser.parseFromString(alertString, "application/xml");

    return alertDoc
}

function createActivityIndicator(title) {
    const markup = `<?xml version="1.0" encoding="UTF-8" ?>
    <document>
    <loadingTemplate>
    <activityIndicator>
    <text>${title}</text>
    </activityIndicator>
    </loadingTemplate>
    </document>`;

    return new DOMParser().parseFromString(markup, "application/xml")
}

function createStackTemplate(shelfTitles) {
    const markup = `<?xml version="1.0" encoding="UTF-8" ?>
    <document>
    <stackTemplate>
    <banner>
    <background>
    <img src="resource://banner" width="1920" height="500" />
    </background>
    </banner>

    <collectionList>
    ${shelfTitles.map(createShelfElement).join("")}
    </collectionList>
    </stackTemplate>
    </document>`;

    return new DOMParser().parseFromString(markup, "application/xml")
}

function createShelfElement(genre) {
    return `<shelf>
    <header>
    <title>${genre}</title>
    </header>
    <section>
    ${genres[genre].map(createLockupElement).join("")}
    </section>
    </shelf>`;
}

function createLockupElement(movie) {
    return `<lockup trailerURL="${movie.trailerURL}">
    <img width="250" height="370" src="${movie.coverURL}" />
    <title>${movie.title}</title>
    </lockup>`;
}

function playSelectedMovie(event) {
    const selectedMovie = event.target;
    const trailerURL = selectedMovie.getAttribute("trailerURL");
    playMovie(trailerURL)
}

function playMovie(url) {
    const mediaItem = new MediaItem("video", url);
    mediaItem.title = "Trailer";

    const playlist = new Playlist();
    playlist.push(mediaItem);

    const player = new Player();
    player.playlist = playlist;

    player.play();
}

function zoomSelectedMovie(event) {
    const selectedMovie = event.target;
    const trailerURL = selectedMovie.getAttribute("trailerURL");
    zoomTrailer(trailerURL);
}

function zoomTrailer(trailerURL) {
    const movie = movies[trailerURL];

    loadData(App.baseURL + "/product.xml", function (template) {
         template = template.replace(/\[GENRE\]/g, movie.genre);
         template = template.replace("[TITLE]", movie.title);
         template = template.replace("[SUMMARY]", movie.summary);
         template = template.replace("[COVERURL]", movie.coverURL);
         template = template.replace("[DIRECTOR]", movie.director);
         template = template.replace("[RELEASEDATE]", movie.releaseDate);
         template = template.replace("[PRICE]", `Available to buy on iTunes for ${movie.price}`);
         template = template.replace("[TRAILERURL]", movie.trailerURL);

         const otherMovies = genres[movie.genre];
         const alternatives = otherMovies.map(createAlternativeMovie).join("");
         template = template.replace("[ALTERNATIVES]", alternatives);

         let document = new DOMParser().parseFromString(template, "application/xml")
         document.addEventListener("select", handleProductEvent);
         document.addEventListener("play", handleProductEvent);
         navigationDocument.pushDocument(document);
     });
}

function createAlternativeMovie(movie) {
    return `<lockup trailerURL="${movie.trailerURL}">
    <img width="200" height="300" src="${movie.coverURL}" />
    <title>${movie.title}</title>
    </lockup>`;
}

function handleProductEvent(event) {
    const target = event.target;

    if (target.tagName === "description") {
        const body = target.textContent;
        const alertDocument = createAlert('', body);
        navigationDocument.presentModal(alertDocument);
    } else if (target.tagName === "lockup") {
        const trailerURL = target.getAttribute("trailerURL");
        zoomTrailer(trailerURL);
    } else {
        const trailerURL = target.getAttribute("trailerURL");
        playMovie(trailerURL);
    }
}
