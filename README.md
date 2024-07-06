# California Fires History DB

Tracking fire data from www.fire.ca.gov/incidents.

This project is inspired by and adapts the work from [simonw/ca-fires-history](https://github.com/simonw/ca-fires-history). Instead of using [Git scraping](https://simonwillison.net/2020/Oct/9/git-scraping/), this project stores the data in a SQLite database and uses GitHub artifacts for storage.

[Read more...]()

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
        end
        subgraph Artifacts
            db[(fires.db)]
            class db artifacts;
        end
    end

    subgraph CAL FIRE
        api[www.fire.ca.gov/incidents]
    end

    db --> |1. Download| scraper
    api --> |2. Fetch Data| scraper
    scraper --> |3. Upload| db
    scraper --> |4. Publish| deployment
    deployment --> |5. View/Access Data| client[User]
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
