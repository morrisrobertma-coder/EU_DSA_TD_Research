#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 00_prelimary_analysis ----
# Purpose of Script: Import collected data and perform inital analysis
#                    into interesting topics
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initialisation
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Libraries
import numpy as np
import pyarrow.parquet as pq
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns

# Input/Output Paths
inp_path = "C:/Users/morri/OneDrive/00_Documents/06_university/00_university_of_sussex/05_summer_semester/05_dissertation/00_data/08_collected/"

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Import Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~
df = pq.read_table(f"{inp_path}2026-03-09_quant.parquet")
df = df.to_pandas()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Overview Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
df_totals = df.groupby("platform")["total_sor_entries"].sum().reset_index()
df_totals["rel_entries"] = df_totals["total_sor_entries"]/df_totals.loc[df_totals["platform"] == "all", "total_sor_entries"].sum()*100
df_totals["rel_entries"] = df_totals["rel_entries"].round(2)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Visulisation
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
df_plot = df[df["platform"] != "all"]

sns.lineplot(data = df_plot, x="date", y="content_type_synthetic_media",hue="platform")

ax = plt.gca()
_= ax.xaxis.set_major_formatter(mdates.DateFormatter('%d'))
_= plt.xticks(rotation=45, fontsize = 9)
_= plt.xlabel("Day - Februray 2026")
_= plt.ylabel("Synthetic Media - Nominal")
_= plt.title("Reported levels of synthetic media moderated in February 2026")