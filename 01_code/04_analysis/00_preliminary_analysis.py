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
# Total aggregation
df_totals = df.groupby("platform")["total_sor_entries"].sum().reset_index()
df_totals["rel_entries"] = df_totals["total_sor_entries"]/df_totals.loc[df_totals["platform"] == "all", "total_sor_entries"].sum()*100
df_totals["rel_entries"] = df_totals["rel_entries"].round(2)

# Synthetic Media Overview
df_syn = df[["platform","date","content_type_synthetic_media"]]
df_syn = df.groupby("platform")["content_type_synthetic_media"].sum().reset_index()
df_syn["rel"] = df_syn["content_type_synthetic_media"]/df_syn.loc[df_syn["platform"] == "all", "content_type_synthetic_media"].sum()*100
df_syn["rel"] = df_syn["rel"].round(2)
df_syn["rel_to_all"] = df_syn["content_type_synthetic_media"]/df_totals.loc[df_totals["platform"] == "all", "total_sor_entries"].sum()*100
df_syn["rel_to_all"] = df_syn["rel_to_all"].round(2)

# Content Types for Snapchat
df_snap = df[(df["platform"] == "snapchat") | (df["platform"] == "tiktok")
             | (df["platform"] == "youtube")]
df_snap = df_snap[["platform","date","total_sor_entries","content_type_audio",
                   "content_type_image","content_type_product",
                   "content_type_synthetic_media",
                   "content_type_text","content_type_video",
                   "content_type_other",
                   "content_type_multiple"]]

df_snap = df_snap.groupby("platform").sum().reset_index()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Visulisation
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(12,5))

# Total SOR Entries 
sns.lineplot(data = df, x="date", y="total_sor_entries",hue="platform", ax=axes[0])

ax = plt.sca(axes[0])
_= axes[0].xaxis.set_major_formatter(mdates.DateFormatter('%d'))
_= axes[0].legend(title = "Platform")
_= axes[0].tick_params(axis='x', rotation=45, labelsize=9)
_= axes[0].set_xlabel("Day - Februray 2026")
_= axes[0].set_ylabel("Total SOR Entries - Nominal")
_= axes[0].set_title("Reported nominal amounts of content moderated in February 2026",
                     fontsize=9)

# Levels of Synthetic Media
#df_plot = df[df["platform"] != "all"]
df_plot = df

sns.lineplot(data = df_plot, x="date",
              y="content_type_synthetic_media", hue="platform", ax=axes[1])

ax = plt.sca(axes[1])
_= axes[1].xaxis.set_major_formatter(mdates.DateFormatter('%d'))
_= axes[1].legend(title = "Platform")
_= axes[1].tick_params(axis='x', rotation=45, labelsize=9)
_= axes[1].set_xlabel("Day - Februray 2026")
_= axes[1].set_ylabel("Synthetic Media - Nominal")
_= axes[1].set_title("Reported levels of synthetic media moderated in February 2026",
                     fontsize=9)