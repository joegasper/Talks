# Chat History: Generate URL Shortener for Azure Static Web App on Linux

## Requests

### Request

I have a project using Azure Static Web app for Linux. I want to have CI/CD with a GitHub private repo. I want the simplest method for a URL shortener web site that for now can be fully manual process by updating a json file in the repo with the URL, shortened URL stub, and a owner/creator email address. You could use a framework like React (your choice). Can you do this?

### Response

Sure, I can guide you through the process. Here's a simplified version of what you're asking for, using React and Azure Static Web Apps.

1. **Create a new React application**

```bash
npx create-react-app url-shortener
cd url-shortener
```

2. **Create a new JSON file** in the `src` directory named `urls.json` with the following structure:

```json
[
  {
    "url": "https://example.com",
    "shortUrl": "exmpl",
    "owner": "owner@example.com"
  }
]
```

3. **Create a new component** `ShortUrl.js` in the `src` directory:

```jsx
import React from 'react';
import urls from './urls.json';

const ShortUrl = () => {
  return (
    <div>
      {urls.map((url, index) => (
        <div key={index}>
          <p>URL: {url.url}</p>
          <p>Short URL: {url.shortUrl}</p>
          <p>Owner: {url.owner}</p>
        </div>
      ))}
    </div>
  );
};

export default ShortUrl;
```

4. **Update `App.js`** to include the `ShortUrl` component:

```jsx
import React from 'react';
import './App.css';
import ShortUrl from './ShortUrl';

function App() {
  return (
    <div className="App">
      <ShortUrl />
    </div>
  );
}

export default App;
```

5. **Push your code to a private GitHub repository**.

6. **Create a new Azure Static Web App**:

   - Sign in to the Azure portal.
   - Select "Create a resource".
   - Search for and select "Static Web App".
   - Select "Create".
   - Fill in the details (Subscription, Resource Group, Name, Region).
   - For "Source", select "GitHub" and authorize Azure to access your GitHub account.
   - Select your repository and branch.
   - For "Build Details", select "Custom" and enter the following details:
     - App location: `/`
     - Api location: `api`
     - App artifact location: `build`
   - Select "Review + Create" and then "Create".

7. **Update your GitHub repository** whenever you want to add a new URL. The Azure Static Web App will automatically update.

This is a very basic implementation and doesn't include any form of authentication or validation. You might want to consider adding these in a production environment.

### Request

Assume the Azure Static Web app has a FQDN of shorturl.com. I want someone to request shorturl.com/exmpl and be redirected (301) to www.example.com.

### Response

To achieve this, you would need to create a serverless Azure Function that handles the redirection. Azure Static Web Apps automatically creates an API endpoint at `/api` that maps to an Azure Functions app.

Here's a step-by-step guide:

1. **Create a new folder** in your project root named `api`.

2. **Create a new file** in the `api` directory named `redirect.js` with the following content:

```javascript
const urls = require('../src/urls.json');

module.exports = async function (context, req) {
  const shortUrl = req.params.shortUrl;
  const url = urls.find(u => u.shortUrl === shortUrl);

  if (url) {
    context.res = {
      status: 301,
      headers: {
        'Location': url.url
      },
      body: ''
    };
  } else {
    context.res = {
      status: 404,
      body: 'Not found'
    };
  }
};
```

This function will look for the `shortUrl` in your `urls.json` file and, if found, will return a 301 redirect to the original URL. If not found, it will return a 404 error.

3. **Update your `routes.json` file** in the `staticwebapp.config.json` file in your project root:

```json
{
  "routes": [
    {
      "route": "/api/redirect/{shortUrl}",
      "serve": "/api/redirect",
      "statusCode": 301
    }
  ]
}
```

This will map any request to `/api/redirect/{shortUrl}` to the `redirect` function, passing the `shortUrl` as a parameter.

4. **Push your changes** to your GitHub repository.

Now, when you navigate to `shorturl.com/api/redirect/exmpl`, you will be redirected to `www.example.com`.

Please note that this is a basic implementation and doesn't include any form of authentication or validation. You might want to consider adding these in a production environment.

### Request

But how does this work if the user requests shorturl.com/exmpl ??   From your last response it seems I would have to request shorturl.com/api/redirect/exmpl  ??

### Response

I apologize for the confusion. You're correct. In the previous example, the redirection would work if the user requests `shorturl.com/api/redirect/exmpl`. 

To make it work for `shorturl.com/exmpl`, you need to adjust the `routes` configuration in the `staticwebapp.config.json` file. 

Here's how you can do it:

1. **Create a `staticwebapp.config.json` file** in your project root with the following content:

```json
{
  "routes": [
    {
      "route": "/:shortUrl",
      "serve": "/api/redirect",
      "statusCode": 301
    }
  ]
}
```

This configuration will route any request to `shorturl.com/{shortUrl}` to the `redirect` function, passing the `shortUrl` as a parameter.

2. **Update the `redirect.js` file** in the `api` directory:

```javascript
const urls = require('../src/urls.json');

module.exports = async function (context, req) {
  const shortUrl = context.bindingData.shortUrl;
  const url = urls.find(u => u.shortUrl === shortUrl);

  if (url) {
    context.res = {
      status: 301,
      headers: {
        'Location': url.url
      },
      body: ''
    };
  } else {
    context.res = {
      status: 404,
      body: 'Not found'
    };
  }
};
```

This function will look for the `shortUrl` in your `urls.json` file and, if found, will return a 301 redirect to the original URL. If not found, it will return a 404 error.

3. **Push your changes** to your GitHub repository.

Now, when you navigate to `shorturl.com/exmpl`, you will be redirected to `www.example.com`.
