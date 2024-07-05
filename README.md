# California Fires History

Tracking fire data from www.fire.ca.gov/incidents.

This project is inspired by and adapts the work from [simonw/ca-fires-history](https://github.com/simonw/ca-fires-history). Instead of using [Git scraping](https://simonwillison.net/2020/Oct/9/git-scraping/), this project stores the data in a SQLite database and uses GitHub artifacts for storage.

## How It Works

```mermaid
graph TB
		subgraph Vercel
		        deployment[Datasette]
		        class deployment vercel;
		    end


    subgraph GitHub
        subgraph Actions
            scraper[scrape.py]
            class scraper actions;
        end
        subgraph Artifacts
            db[(fires.db)]
            class db artifacts;
        end
    end

    subgraph Web
        web[www.fire.ca.gov/incidents]
        class api Web;
    end

    db --> |1. Download| scraper
    web --> |2. Fetch Data| scraper
    scraper --> |3. Upload| db
    scraper --> |4. Publish| deployment
    deployment --> |5. View/Access Data| client[User]


    %% Apply dotted line styles
    style GitHub stroke-dasharray: 5 5;
    style Web stroke-dasharray: 5 5;
```

## Usage

### Running the Script

To run the script locally and update the database:

```bash
python3 scrape.py
```

### Optional: Running Datasette

To view and explore the data using [Datasette](https://datasette.io/):

```sh
pip install datasette # optional: install Datasette if you haven't already

datasette data/fires.db --metadata data/metadata.json
```
