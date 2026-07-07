# COVID-19 Data Analysis Project

This project analyzes COVID-19 trends in India using state-level case data and vaccination statistics. It includes exploratory analysis, visualizations, and summary tables created in the Jupyter notebook.

## Project structure

- `Covid-Data-Analysis-Python.ipynb` — main notebook for data cleaning, analysis, and visualization
- `covid_19_india.csv` — state/UT-level case dataset covering confirmed, cured, deaths, and active case calculations
- `covid_vaccine_statewise.csv` — vaccine dose totals by state/UT and date
- `StatewiseTestingDetails.csv` — state/UT testing metrics data

## Analysis goals

- Clean and prepare COVID-19 case data for India
- Calculate active cases from confirmed, cured, and death counts
- Compare states by confirmed cases, recoveries, and mortality
- Visualize top states with the highest active cases and deaths
- Plot trends for major affected states over time
- Explore vaccine progress with statewise data

## Key findings (notebook highlights)

- The notebook computes active cases from the base case dataset
- Highest active-case states are visualized with a bar chart
- Death statistics are ranked and plotted by state
- Time series trends compare major impact states such as Maharashtra, Karnataka, Kerala, Tamil Nadu, and Uttar Pradesh
- Vaccine dataset is loaded and prepared for analysis

## How to use

1. Install Python packages:

```bash
pip install pandas numpy matplotlib seaborn plotly jupyter
```

2. Open the notebook:

```bash
jupyter notebook Covid-Data-Analysis-Python.ipynb
```

3. Run cells in order.

## Data preparation notes

- The case file is loaded from `covid_19_india.csv`
- The notebook drops unused columns like `Sno`, `Time`, `ConfirmedIndianNational`, and `ConfirmedForeignNational`
- Dates are converted to `datetime` objects for plotting
- Active cases are derived as `Confirmed - (Cured + Deaths)`

## Next improvements

- Add more statewise comparison charts for vaccination totals
- Compute rolling averages and daily case trends
- Create a dashboard with Plotly or Streamlit
- Add summary metrics for latest date per state

## License

Add your preferred license here (e.g. MIT).
