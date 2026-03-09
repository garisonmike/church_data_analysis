"""
Church Data Complete Analysis
==============================
Comprehensive statistical analysis, computations, and data visualizations
for church attendance and financial data.
Dataset 1: 10-week historical data (NO1-NO10)
Dataset 2: Jan-Feb 2026 dated records with targets
Combined: Cross-dataset comparative analysis
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

import os
import warnings
warnings.filterwarnings('ignore')

# Create output directories
os.makedirs('church_analysis', exist_ok=True)
os.makedirs('church_analysis/dataset1', exist_ok=True)
os.makedirs('church_analysis/dataset2', exist_ok=True)
os.makedirs('church_analysis/combined', exist_ok=True)

# ============================================
# DATASET 1 SETUP
# ============================================

data = {
    'SATURDAY': ['17-01-2026', '24-01-2026', '31-01-2026', '07-02-2026'],
    'MEN': [546, 480, 506, 439],
    'WOMEN': [758, 680, 739, 598],
    'YOUTH': [386, 354, 345, 395],
    'CHILDREN': [496, 429, 494, 490],
    'SUNDAY_HOME_CHURCH': [302, 303, 278, 235],
    'TITHE': [338731.00, 680280.00, 481608.00, 489667.00],
    'OFFERINGS': [70514.00, 74895.00, 71207.00, 61876.00],
    'EMERGENCY_COLLECTION': [0, 0, 0, 0],
    'PLANNED_COLLECTION': [0, 0, 0, 0]
}

df = pd.DataFrame(data)

# ============================================
# DATASET 2 SETUP (Jan-Feb 2026 + Targets)
# ============================================

data2 = {
    'DATE': ['17-01-2026', '24-01-2026', '31-01-2026', '07-02-2026'],
    'MEN': [546, 480, 506, 439],
    'WOMEN': [758, 680, 739, 598],
    'YOUTH': [386, 354, 345, 395],
    'CHILDREN': [496, 429, 494, 490],
    'TOTAL_ATTENDANCE': [2186, 1943, 2084, 1922],
    'HOME_CHURCH': [302, 303, 278, 235],
    'TITHE': [338731.00, 680280.00, 481608.00, 489667.00],
    'OFFERINGS': [70514.00, 74895.00, 71207.00, 61876.00],
    'BAPTISMS': [45, None, None, None],
}

df2 = pd.DataFrame(data2)
df2['BAPTISMS'] = pd.to_numeric(df2['BAPTISMS'], errors='coerce')

# Targets for Dataset 2
targets2 = {
    'MEN': 900, 'WOMEN': 1200, 'YOUTH': 800, 'CHILDREN': 1000,
    'TOTAL_ATTENDANCE': 3900, 'HOME_CHURCH': 2000,
    'TITHE': 1050000.00, 'OFFERINGS': 450000.00, 'BAPTISMS': 500
}

# ============================================
# DATASET 2 DERIVED COLUMNS
# ============================================

df2['TOTAL_INCOME'] = df2['TITHE'] + df2['OFFERINGS']
df2['ADULT_ATTENDANCE'] = df2['MEN'] + df2['WOMEN']
df2['YOUNG_ATTENDANCE'] = df2['YOUTH'] + df2['CHILDREN']
df2['INCOME_PER_ATTENDEE'] = df2['TOTAL_INCOME'] / df2['TOTAL_ATTENDANCE']
df2['TITHE_PER_ATTENDEE'] = df2['TITHE'] / df2['TOTAL_ATTENDANCE']
df2['OFFERINGS_PER_ATTENDEE'] = df2['OFFERINGS'] / df2['TOTAL_ATTENDANCE']
df2['MEN_PCT'] = (df2['MEN'] / df2['TOTAL_ATTENDANCE']) * 100
df2['WOMEN_PCT'] = (df2['WOMEN'] / df2['TOTAL_ATTENDANCE']) * 100
df2['YOUTH_PCT'] = (df2['YOUTH'] / df2['TOTAL_ATTENDANCE']) * 100
df2['CHILDREN_PCT'] = (df2['CHILDREN'] / df2['TOTAL_ATTENDANCE']) * 100
df2['MEN_WOMEN_RATIO'] = df2['MEN'] / df2['WOMEN']
df2['ADULT_YOUNG_RATIO'] = df2['ADULT_ATTENDANCE'] / df2['YOUNG_ATTENDANCE']
df2['TITHE_OFFERINGS_RATIO'] = df2['TITHE'] / df2['OFFERINGS']
df2['ATTENDANCE_GROWTH'] = df2['TOTAL_ATTENDANCE'].pct_change() * 100
df2['TITHE_GROWTH'] = df2['TITHE'].pct_change() * 100
df2['WEEK'] = range(1, len(df2) + 1)
# Target achievement percentages
df2['MEN_TARGET_PCT'] = (df2['MEN'] / targets2['MEN']) * 100
df2['WOMEN_TARGET_PCT'] = (df2['WOMEN'] / targets2['WOMEN']) * 100
df2['YOUTH_TARGET_PCT'] = (df2['YOUTH'] / targets2['YOUTH']) * 100
df2['CHILDREN_TARGET_PCT'] = (df2['CHILDREN'] / targets2['CHILDREN']) * 100
df2['TOTAL_ATT_TARGET_PCT'] = (df2['TOTAL_ATTENDANCE'] / targets2['TOTAL_ATTENDANCE']) * 100
df2['HOME_CHURCH_TARGET_PCT'] = (df2['HOME_CHURCH'] / targets2['HOME_CHURCH']) * 100
df2['TITHE_TARGET_PCT'] = (df2['TITHE'] / targets2['TITHE']) * 100
df2['OFFERINGS_TARGET_PCT'] = (df2['OFFERINGS'] / targets2['OFFERINGS']) * 100

# ============================================
# DATASET 1 DERIVED COLUMNS
# ============================================

# Attendance metrics
df['TOTAL_ATTENDANCE'] = df['MEN'] + df['WOMEN'] + df['YOUTH'] + df['CHILDREN']
df['TOTAL_WITH_HOME_CHURCH'] = df['TOTAL_ATTENDANCE'] + df['SUNDAY_HOME_CHURCH']
df['ADULT_ATTENDANCE'] = df['MEN'] + df['WOMEN']
df['YOUNG_ATTENDANCE'] = df['YOUTH'] + df['CHILDREN']

# Financial metrics
df['TOTAL_INCOME'] = df['TITHE'] + df['OFFERINGS'] + df['EMERGENCY_COLLECTION'] + df['PLANNED_COLLECTION']
df['REGULAR_INCOME'] = df['TITHE'] + df['OFFERINGS']
df['SPECIAL_COLLECTIONS'] = df['EMERGENCY_COLLECTION'] + df['PLANNED_COLLECTION']

# Percentage columns
df['MEN_PCT'] = (df['MEN'] / df['TOTAL_ATTENDANCE']) * 100
df['WOMEN_PCT'] = (df['WOMEN'] / df['TOTAL_ATTENDANCE']) * 100
df['YOUTH_PCT'] = (df['YOUTH'] / df['TOTAL_ATTENDANCE']) * 100
df['CHILDREN_PCT'] = (df['CHILDREN'] / df['TOTAL_ATTENDANCE']) * 100

# Per capita metrics
df['INCOME_PER_ATTENDEE'] = df['TOTAL_INCOME'] / df['TOTAL_ATTENDANCE']
df['TITHE_PER_ATTENDEE'] = df['TITHE'] / df['TOTAL_ATTENDANCE']
df['OFFERINGS_PER_ATTENDEE'] = df['OFFERINGS'] / df['TOTAL_ATTENDANCE']
df['REGULAR_INCOME_PER_ADULT'] = df['REGULAR_INCOME'] / df['ADULT_ATTENDANCE']

# Growth metrics
df['ATTENDANCE_GROWTH'] = df['TOTAL_ATTENDANCE'].pct_change() * 100
df['INCOME_GROWTH'] = df['TOTAL_INCOME'].pct_change() * 100
df['TITHE_GROWTH'] = df['TITHE'].pct_change() * 100

# Ratios
df['MEN_WOMEN_RATIO'] = df['MEN'] / df['WOMEN']
df['ADULT_YOUNG_RATIO'] = df['ADULT_ATTENDANCE'] / df['YOUNG_ATTENDANCE']
df['TITHE_OFFERINGS_RATIO'] = df['TITHE'] / df['OFFERINGS']

# Week number for analysis
df['WEEK'] = range(1, 5)

# Set style
plt.style.use('seaborn-v0_8-whitegrid')

# ============================================
# STATISTICAL COMPUTATIONS
# ============================================

def compute_all_statistics():
    """Compute and display all possible statistics"""
    
    print("\n" + "="*80)
    print("COMPREHENSIVE CHURCH DATA STATISTICAL ANALYSIS")
    print("="*80)
    
    # Basic Statistics
    print("\n" + "-"*80)
    print("1. BASIC DESCRIPTIVE STATISTICS")
    print("-"*80)
    
    numeric_cols = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'SUNDAY_HOME_CHURCH',
                    'TITHE', 'OFFERINGS', 'EMERGENCY_COLLECTION', 'PLANNED_COLLECTION',
                    'TOTAL_ATTENDANCE', 'TOTAL_INCOME']
    
    stats_df = df[numeric_cols].describe()
    print(stats_df.to_string())
    
    # Additional statistics
    print("\n" + "-"*80)
    print("2. ADDITIONAL STATISTICAL MEASURES")
    print("-"*80)
    
    for col in numeric_cols:
        print(f"\n{col}:")
        print(f"  Sum:         {df[col].sum():,.0f}")
        print(f"  Mean:        {df[col].mean():,.2f}")
        print(f"  Median:      {df[col].median():,.2f}")
        print(f"  Mode:        {df[col].mode().values[0]:,.0f}" if len(df[col].mode()) > 0 else "  Mode: N/A")
        print(f"  Std Dev:     {df[col].std():,.2f}")
        print(f"  Variance:    {df[col].var():,.2f}")
        print(f"  Min:         {df[col].min():,.0f}")
        print(f"  Max:         {df[col].max():,.0f}")
        print(f"  Range:       {df[col].max() - df[col].min():,.0f}")
        print(f"  IQR:         {df[col].quantile(0.75) - df[col].quantile(0.25):,.2f}")
        print(f"  Skewness:    {df[col].skew():.4f}")
        print(f"  Kurtosis:    {df[col].kurtosis():.4f}")
        print(f"  CV (%):      {(df[col].std() / df[col].mean()) * 100:.2f}")
    
    # Totals and Aggregates
    print("\n" + "-"*80)
    print("3. TOTALS AND AGGREGATES")
    print("-"*80)
    
    print("\nATTENDANCE TOTALS:")
    print(f"  Total Men (all weeks):             {df['MEN'].sum():,}")
    print(f"  Total Women (all weeks):           {df['WOMEN'].sum():,}")
    print(f"  Total Youth (all weeks):           {df['YOUTH'].sum():,}")
    print(f"  Total Children (all weeks):        {df['CHILDREN'].sum():,}")
    print(f"  Total Sunday Home Church:          {df['SUNDAY_HOME_CHURCH'].sum():,}")
    print(f"  Grand Total Attendance:            {df['TOTAL_ATTENDANCE'].sum():,}")
    print(f"  Grand Total with Home Church:      {df['TOTAL_WITH_HOME_CHURCH'].sum():,}")
    
    print("\nFINANCIAL TOTALS:")
    print(f"  Total Tithe:                       {df['TITHE'].sum():,}")
    print(f"  Total Offerings:                   {df['OFFERINGS'].sum():,}")
    print(f"  Total Emergency Collection:        {df['EMERGENCY_COLLECTION'].sum():,}")
    print(f"  Total Planned Collection:          {df['PLANNED_COLLECTION'].sum():,}")
    print(f"  Grand Total Income:                {df['TOTAL_INCOME'].sum():,}")
    print(f"  Total Regular Income:              {df['REGULAR_INCOME'].sum():,}")
    print(f"  Total Special Collections:         {df['SPECIAL_COLLECTIONS'].sum():,}")
    
    # Percentages and Proportions
    print("\n" + "-"*80)
    print("4. PERCENTAGE DISTRIBUTIONS")
    print("-"*80)
    
    total_att = df['TOTAL_ATTENDANCE'].sum()
    total_inc = df['TOTAL_INCOME'].sum()
    
    print("\nATTENDANCE DISTRIBUTION:")
    print(f"  Men:      {df['MEN'].sum()/total_att*100:.2f}%")
    print(f"  Women:    {df['WOMEN'].sum()/total_att*100:.2f}%")
    print(f"  Youth:    {df['YOUTH'].sum()/total_att*100:.2f}%")
    print(f"  Children: {df['CHILDREN'].sum()/total_att*100:.2f}%")
    
    print("\nINCOME DISTRIBUTION:")
    print(f"  Tithe:                {df['TITHE'].sum()/total_inc*100:.2f}%")
    print(f"  Offerings:            {df['OFFERINGS'].sum()/total_inc*100:.2f}%")
    print(f"  Emergency Collection: {df['EMERGENCY_COLLECTION'].sum()/total_inc*100:.2f}%")
    print(f"  Planned Collection:   {df['PLANNED_COLLECTION'].sum()/total_inc*100:.2f}%")
    
    # Averages
    print("\n" + "-"*80)
    print("5. AVERAGES PER WEEK")
    print("-"*80)
    
    print("\nATTENDANCE AVERAGES:")
    print(f"  Avg Men per week:            {df['MEN'].mean():.0f}")
    print(f"  Avg Women per week:          {df['WOMEN'].mean():.0f}")
    print(f"  Avg Youth per week:          {df['YOUTH'].mean():.0f}")
    print(f"  Avg Children per week:       {df['CHILDREN'].mean():.0f}")
    print(f"  Avg Sunday Home Church:      {df['SUNDAY_HOME_CHURCH'].mean():.0f}")
    print(f"  Avg Total Attendance:        {df['TOTAL_ATTENDANCE'].mean():.0f}")
    
    print("\nFINANCIAL AVERAGES:")
    print(f"  Avg Tithe per week:          {df['TITHE'].mean():,.0f}")
    print(f"  Avg Offerings per week:      {df['OFFERINGS'].mean():,.0f}")
    print(f"  Avg Emergency Collection:    {df['EMERGENCY_COLLECTION'].mean():,.0f}")
    print(f"  Avg Planned Collection:      {df['PLANNED_COLLECTION'].mean():,.0f}")
    print(f"  Avg Total Income:            {df['TOTAL_INCOME'].mean():,.0f}")
    
    # Per Capita Metrics
    print("\n" + "-"*80)
    print("6. PER CAPITA METRICS (OVERALL AVERAGES)")
    print("-"*80)
    
    print(f"  Avg Income per Attendee:           {df['INCOME_PER_ATTENDEE'].mean():,.2f}")
    print(f"  Avg Tithe per Attendee:            {df['TITHE_PER_ATTENDEE'].mean():,.2f}")
    print(f"  Avg Offerings per Attendee:        {df['OFFERINGS_PER_ATTENDEE'].mean():,.2f}")
    print(f"  Avg Regular Income per Adult:      {df['REGULAR_INCOME_PER_ADULT'].mean():,.2f}")
    
    # Ratios
    print("\n" + "-"*80)
    print("7. KEY RATIOS")
    print("-"*80)
    
    print(f"  Overall Men:Women Ratio:           {df['MEN'].sum()/df['WOMEN'].sum():.3f}")
    print(f"  Overall Adult:Young Ratio:         {df['ADULT_ATTENDANCE'].sum()/df['YOUNG_ATTENDANCE'].sum():.3f}")
    print(f"  Overall Tithe:Offerings Ratio:     {df['TITHE'].sum()/df['OFFERINGS'].sum():.3f}")
    print(f"  Regular:Special Income Ratio:      {df['REGULAR_INCOME'].sum()/max(df['SPECIAL_COLLECTIONS'].sum(), 1):.3f}")
    
    # Growth Analysis
    print("\n" + "-"*80)
    print("8. GROWTH ANALYSIS")
    print("-"*80)
    
    print("\nWeek-over-Week Attendance Growth (%):")
    for i, (week, growth) in enumerate(zip(df['SATURDAY'], df['ATTENDANCE_GROWTH'])):
        if pd.notna(growth):
            print(f"  {week}: {growth:+.2f}%")
    
    print(f"\n  Average Weekly Attendance Growth: {df['ATTENDANCE_GROWTH'].mean():.2f}%")
    print(f"  Max Weekly Growth: {df['ATTENDANCE_GROWTH'].max():.2f}%")
    print(f"  Min Weekly Growth: {df['ATTENDANCE_GROWTH'].min():.2f}%")
    
    # Trend Analysis
    print("\n" + "-"*80)
    print("9. LINEAR TREND ANALYSIS")
    print("-"*80)
    
    trend_vars = ['TOTAL_ATTENDANCE', 'TITHE', 'OFFERINGS', 'TOTAL_INCOME']
    for var in trend_vars:
        slope, intercept, r_value, p_value, std_err = stats.linregress(df['WEEK'], df[var])
        print(f"\n{var} Trend:")
        print(f"  Slope:      {slope:,.2f} per week")
        print(f"  Intercept:  {intercept:,.2f}")
        print(f"  R-squared:  {r_value**2:.4f}")
        print(f"  P-value:    {p_value:.4f}")
        print(f"  Trend:      {'Increasing' if slope > 0 else 'Decreasing'}")
    
    # Peak and Low Analysis
    print("\n" + "-"*80)
    print("10. PEAK AND LOW ANALYSIS")
    print("-"*80)
    
    analysis_cols = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'TOTAL_ATTENDANCE',
                     'TITHE', 'OFFERINGS', 'TOTAL_INCOME']
    
    for col in analysis_cols:
        max_idx = df[col].idxmax()
        min_idx = df[col].idxmin()
        print(f"\n{col}:")
        print(f"  Peak: Week {max_idx + 1} ({df['SATURDAY'][max_idx]}): {df[col].max():,.0f}")
        print(f"  Low:  Week {min_idx + 1} ({df['SATURDAY'][min_idx]}): {df[col].min():,.0f}")

def create_statistics_table():
    """Create and save comprehensive statistics table"""
    
    # Create summary statistics DataFrame
    numeric_cols = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'SUNDAY_HOME_CHURCH',
                    'TITHE', 'OFFERINGS', 'EMERGENCY_COLLECTION', 'PLANNED_COLLECTION']
    
    stats_data = []
    for col in numeric_cols:
        stats_data.append({
            'Variable': col,
            'Sum': df[col].sum(),
            'Mean': df[col].mean(),
            'Median': df[col].median(),
            'Std Dev': df[col].std(),
            'Min': df[col].min(),
            'Max': df[col].max(),
            'Range': df[col].max() - df[col].min(),
            'CV (%)': (df[col].std() / df[col].mean()) * 100,
            'Skewness': df[col].skew(),
            'Kurtosis': df[col].kurtosis()
        })
    
    stats_table = pd.DataFrame(stats_data)
    stats_table.to_csv('church_analysis/dataset1/statistics_summary.csv', index=False)
    print("\nSaved: dataset1/statistics_summary.csv")
    
    return stats_table

# ============================================
# DATA GRAPHS
# ============================================

def plot_attendance_overview():
    """Grouped bar chart overview of all attendance groups and income per week"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x = np.arange(len(df['SATURDAY']))
    width = 0.2
    groups = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN']
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']

    ax1 = axes[0]
    for i, (grp, color) in enumerate(zip(groups, colors)):
        ax1.bar(x + i * width, df[grp], width, label=grp.title(), color=color, alpha=0.8)
    ax1.set_xticks(x + width * 1.5)
    ax1.set_xticklabels(df['SATURDAY'], rotation=20, ha='right')
    ax1.set_title('Attendance by Group per Week', fontweight='bold')
    ax1.set_ylabel('Attendance')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)

    ax2 = axes[1]
    ax2.bar(df['SATURDAY'], df['TITHE'] / 1000, color='#27ae60', alpha=0.8, label='Tithe')
    ax2.bar(df['SATURDAY'], df['OFFERINGS'] / 1000, bottom=df['TITHE'] / 1000,
            color='#3498db', alpha=0.8, label='Offerings')
    ax2.set_title('Income by Week', fontweight='bold')
    ax2.set_ylabel('Amount (Thousands)')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)

    plt.suptitle('Attendance & Income Overview', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/attendance_income_overview.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset1/attendance_income_overview.png")


def plot_demographics_weekly():
    """Bar charts of each demographic group and key financial variable per week"""
    fig, axes = plt.subplots(2, 4, figsize=(18, 10))

    demographics = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN']
    financials = ['TITHE', 'OFFERINGS', 'TOTAL_INCOME', 'SUNDAY_HOME_CHURCH']
    colors_d = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    colors_f = ['#27ae60', '#9b59b6', '#e74c3c', '#1abc9c']

    for i, (demo, color) in enumerate(zip(demographics, colors_d)):
        ax = axes[0, i]
        ax.bar(df['SATURDAY'], df[demo], color=color, alpha=0.8)
        ax.axhline(df[demo].mean(), color='black', linestyle='--', linewidth=1.5,
                   label=f'Mean: {df[demo].mean():.0f}')
        ax.set_title(f'{demo} per Week', fontweight='bold')
        ax.set_ylabel('Attendance')
        ax.legend(fontsize=9)
        ax.grid(axis='y', alpha=0.3)
        ax.tick_params(axis='x', rotation=20)

    for i, (fin, color) in enumerate(zip(financials, colors_f)):
        ax = axes[1, i]
        divisor = 1000 if fin in ['TITHE', 'OFFERINGS', 'TOTAL_INCOME'] else 1
        ylabel = f'{fin} (K)' if divisor == 1000 else fin
        ax.bar(df['SATURDAY'], df[fin] / divisor, color=color, alpha=0.8)
        ax.axhline((df[fin] / divisor).mean(), color='black', linestyle='--', linewidth=1.5,
                   label=f'Mean: {(df[fin] / divisor).mean():.0f}')
        ax.set_title(f'{fin} per Week', fontweight='bold')
        ax.set_ylabel(ylabel)
        ax.legend(fontsize=9)
        ax.grid(axis='y', alpha=0.3)
        ax.tick_params(axis='x', rotation=20)

    plt.suptitle('Individual Variables per Week', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/demographics_weekly.png', dpi=150)
    plt.show()
    print("Saved: dataset1/demographics_weekly.png")


def plot_attendance_income_trends():
    """Trend charts for total attendance and income variables"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    ax1 = axes[0, 0]
    ax1.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax1.fill_between(df['SATURDAY'], df['TOTAL_ATTENDANCE'], alpha=0.3, color='#9b59b6')
    ax1.axhline(df['TOTAL_ATTENDANCE'].mean(), color='red', linestyle='--',
                label=f"Mean: {df['TOTAL_ATTENDANCE'].mean():.0f}")
    ax1.set_title('Total Attendance per Week', fontweight='bold')
    ax1.set_ylabel('Attendance')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2 = axes[0, 1]
    ax2.bar(df['SATURDAY'], df['TITHE'] / 1000, color='#27ae60', alpha=0.8)
    ax2.axhline(df['TITHE'].mean() / 1000, color='red', linestyle='--',
                label=f"Mean: {df['TITHE'].mean() / 1000:.0f}K")
    ax2.set_title('Tithe per Week', fontweight='bold')
    ax2.set_ylabel('Tithe (Thousands)')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)

    ax3 = axes[1, 0]
    ax3.bar(df['SATURDAY'], df['OFFERINGS'] / 1000, color='#3498db', alpha=0.8)
    ax3.axhline(df['OFFERINGS'].mean() / 1000, color='red', linestyle='--',
                label=f"Mean: {df['OFFERINGS'].mean() / 1000:.0f}K")
    ax3.set_title('Offerings per Week', fontweight='bold')
    ax3.set_ylabel('Offerings (Thousands)')
    ax3.legend()
    ax3.grid(axis='y', alpha=0.3)

    ax4 = axes[1, 1]
    ax4.plot(df['SATURDAY'], df['TOTAL_INCOME'] / 1000, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax4.fill_between(df['SATURDAY'], df['TOTAL_INCOME'] / 1000, alpha=0.3, color='#e74c3c')
    ax4.axhline(df['TOTAL_INCOME'].mean() / 1000, color='blue', linestyle='--',
                label=f"Mean: {df['TOTAL_INCOME'].mean() / 1000:.0f}K")
    ax4.set_title('Total Income per Week', fontweight='bold')
    ax4.set_ylabel('Total Income (Thousands)')
    ax4.legend()
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Attendance & Income Weekly Trends', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/attendance_income_trends.png', dpi=150)
    plt.show()
    print("Saved: dataset1/attendance_income_trends.png")


def plot_demographic_comparison():
    """Side-by-side bar charts comparing every pair of demographic groups per week"""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    pairs = [
        ('MEN', 'WOMEN'), ('MEN', 'YOUTH'), ('MEN', 'CHILDREN'),
        ('WOMEN', 'YOUTH'), ('WOMEN', 'CHILDREN'), ('YOUTH', 'CHILDREN')
    ]
    colors_pair = [
        ('#3498db', '#e74c3c'), ('#3498db', '#2ecc71'), ('#3498db', '#f39c12'),
        ('#e74c3c', '#2ecc71'), ('#e74c3c', '#f39c12'), ('#2ecc71', '#f39c12')
    ]

    for idx, ((var1, var2), (c1, c2)) in enumerate(zip(pairs, colors_pair)):
        ax = axes[idx // 3, idx % 3]
        x = np.arange(len(df['SATURDAY']))
        width = 0.35
        ax.bar(x - width / 2, df[var1], width, label=var1.title(), color=c1, alpha=0.8)
        ax.bar(x + width / 2, df[var2], width, label=var2.title(), color=c2, alpha=0.8)
        ax.set_xticks(x)
        ax.set_xticklabels(df['SATURDAY'], rotation=20, ha='right', fontsize=8)
        ax.set_title(f'{var1} vs {var2}', fontsize=12, fontweight='bold')
        ax.set_ylabel('Attendance')
        ax.legend()
        ax.grid(axis='y', alpha=0.3)

    plt.suptitle('Demographic Group Comparisons per Week', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/demographic_comparison.png', dpi=150)
    plt.show()
    print("Saved: dataset1/demographic_comparison.png")


def plot_financial_weekly():
    """Bar charts comparing financial variable pairs per week"""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    pairs = [
        ('TITHE', 'OFFERINGS'), ('TITHE', 'TOTAL_INCOME'), ('OFFERINGS', 'TOTAL_INCOME')
    ]
    colors_pair = [
        ('#27ae60', '#3498db'), ('#27ae60', '#e74c3c'), ('#3498db', '#e74c3c')
    ]

    for idx, ((var1, var2), (c1, c2)) in enumerate(zip(pairs, colors_pair)):
        ax = axes[idx]
        x = np.arange(len(df['SATURDAY']))
        width = 0.35
        ax.bar(x - width / 2, df[var1] / 1000, width, label=var1.title(), color=c1, alpha=0.8)
        ax.bar(x + width / 2, df[var2] / 1000, width, label=var2.title(), color=c2, alpha=0.8)
        ax.set_xticks(x)
        ax.set_xticklabels(df['SATURDAY'], rotation=20, ha='right', fontsize=9)
        ax.set_xlabel('Week')
        ax.set_ylabel('Amount (K)')
        ax.set_title(f'{var1} vs {var2} per Week', fontsize=12, fontweight='bold')
        ax.legend()
        ax.grid(axis='y', alpha=0.3)

    plt.suptitle('Financial Variables per Week', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/financial_weekly.png', dpi=150)
    plt.show()
    print("Saved: dataset1/financial_weekly.png")


def plot_home_church_comparison():
    """Bar charts comparing Sunday Home Church attendance to all other variables per week"""
    fig, axes = plt.subplots(2, 4, figsize=(18, 10))

    variables = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN',
                 'TITHE', 'OFFERINGS', 'TOTAL_ATTENDANCE', 'TOTAL_INCOME']
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12',
              '#27ae60', '#9b59b6', '#1abc9c', '#e67e22']

    for idx, (var, color) in enumerate(zip(variables, colors)):
        ax = axes[idx // 4, idx % 4]
        y_data = df[var] / 1000 if var in ['TITHE', 'OFFERINGS', 'TOTAL_INCOME'] else df[var]
        x = np.arange(len(df['SATURDAY']))
        width = 0.35
        ax.bar(x - width / 2, df['SUNDAY_HOME_CHURCH'], width,
               label='Home Church', color='#8e44ad', alpha=0.8)
        ax.bar(x + width / 2, y_data, width, label=var, color=color, alpha=0.8)
        ax.set_xticks(x)
        ax.set_xticklabels(df['SATURDAY'], rotation=20, ha='right', fontsize=7)
        ax.set_title(f'Home Church vs {var}', fontsize=11, fontweight='bold')
        ax.set_ylabel('Value')
        ax.legend(fontsize=7)
        ax.grid(axis='y', alpha=0.3)

    plt.suptitle('Sunday Home Church vs All Variables per Week', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/home_church_comparison.png', dpi=150)
    plt.show()
    print("Saved: dataset1/home_church_comparison.png")

def plot_time_series_all():
    """All variables over time"""
    fig, axes = plt.subplots(3, 2, figsize=(14, 14))
    
    # Attendance over time
    ax1 = axes[0, 0]
    ax1.plot(df['SATURDAY'], df['MEN'], 'o-', label='Men', color='#3498db', linewidth=2)
    ax1.plot(df['SATURDAY'], df['WOMEN'], 's-', label='Women', color='#e74c3c', linewidth=2)
    ax1.plot(df['SATURDAY'], df['YOUTH'], '^-', label='Youth', color='#2ecc71', linewidth=2)
    ax1.plot(df['SATURDAY'], df['CHILDREN'], 'd-', label='Children', color='#f39c12', linewidth=2)
    ax1.set_title('Demographic Groups Over Time', fontweight='bold')
    ax1.set_xlabel('Week')
    ax1.set_ylabel('Attendance')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Total attendance trend
    ax2 = axes[0, 1]
    ax2.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax2.fill_between(df['SATURDAY'], df['TOTAL_ATTENDANCE'], alpha=0.3, color='#9b59b6')
    z = np.polyfit(range(len(df)), df['TOTAL_ATTENDANCE'], 1)
    p = np.poly1d(z)
    ax2.plot(df['SATURDAY'], p(range(len(df))), '--', color='red', linewidth=2, label='Trend')
    ax2.set_title('Total Attendance Trend', fontweight='bold')
    ax2.set_xlabel('Week')
    ax2.set_ylabel('Total Attendance')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Regular income over time
    ax3 = axes[1, 0]
    ax3.plot(df['SATURDAY'], df['TITHE']/1000, 'o-', label='Tithe', color='#27ae60', linewidth=2)
    ax3.plot(df['SATURDAY'], df['OFFERINGS']/1000, 's-', label='Offerings', color='#3498db', linewidth=2)
    ax3.set_title('Tithe & Offerings Over Time', fontweight='bold')
    ax3.set_xlabel('Week')
    ax3.set_ylabel('Amount (Thousands)')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # Total income trend
    ax4 = axes[1, 1]
    ax4.plot(df['SATURDAY'], df['TOTAL_INCOME']/1000, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax4.fill_between(df['SATURDAY'], df['TOTAL_INCOME']/1000, alpha=0.3, color='#e74c3c')
    z = np.polyfit(range(len(df)), df['TOTAL_INCOME']/1000, 1)
    p = np.poly1d(z)
    ax4.plot(df['SATURDAY'], p(range(len(df))), '--', color='blue', linewidth=2, label='Trend')
    ax4.set_title('Total Income Trend', fontweight='bold')
    ax4.set_xlabel('Week')
    ax4.set_ylabel('Total Income (Thousands)')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    # Growth rates
    ax5 = axes[2, 0]
    colors_att = ['#27ae60' if x >= 0 else '#e74c3c' for x in df['ATTENDANCE_GROWTH'].fillna(0)]
    ax5.bar(df['SATURDAY'], df['ATTENDANCE_GROWTH'].fillna(0), color=colors_att, alpha=0.7)
    ax5.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax5.set_title('Attendance Growth Rate (%)', fontweight='bold')
    ax5.set_xlabel('Week')
    ax5.set_ylabel('Growth Rate (%)')
    ax5.grid(True, alpha=0.3)
    
    # Income per attendee
    ax6 = axes[2, 1]
    ax6.plot(df['SATURDAY'], df['INCOME_PER_ATTENDEE'], 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax6.fill_between(df['SATURDAY'], df['INCOME_PER_ATTENDEE'], alpha=0.3, color='#9b59b6')
    ax6.set_title('Income Per Attendee Over Time', fontweight='bold')
    ax6.set_xlabel('Week')
    ax6.set_ylabel('Income per Attendee')
    ax6.grid(True, alpha=0.3)
    
    plt.suptitle('Time Series Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/time_series_all.png', dpi=150)
    plt.show()
    print("Saved: dataset1/time_series_all.png")

def plot_distribution_analysis():
    """Distribution analysis for all variables"""
    fig, axes = plt.subplots(3, 3, figsize=(14, 12))
    
    variables = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'SUNDAY_HOME_CHURCH',
                 'TITHE', 'OFFERINGS', 'TOTAL_ATTENDANCE', 'TOTAL_INCOME']
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6',
              '#27ae60', '#1abc9c', '#e67e22', '#8e44ad']
    
    for idx, (var, color) in enumerate(zip(variables, colors)):
        ax = axes[idx // 3, idx % 3]
        
        data = df[var]/1000 if var in ['TITHE', 'OFFERINGS', 'TOTAL_INCOME'] else df[var]
        
        ax.hist(data, bins=6, color=color, alpha=0.7, edgecolor='white', linewidth=1.5)
        ax.axvline(data.mean(), color='red', linestyle='--', linewidth=2, label=f'Mean: {data.mean():.0f}')
        ax.axvline(data.median(), color='blue', linestyle=':', linewidth=2, label=f'Median: {data.median():.0f}')
        
        title = f'{var} (K)' if var in ['TITHE', 'OFFERINGS', 'TOTAL_INCOME'] else var
        ax.set_title(f'{title} Distribution', fontweight='bold')
        ax.set_xlabel(title)
        ax.set_ylabel('Frequency')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Distribution Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/distribution_analysis.png', dpi=150)
    plt.show()
    print("Saved: dataset1/distribution_analysis.png")

def plot_box_plots():
    """Box plots for all variables"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Attendance box plots
    ax1 = axes[0]
    attendance_data = [df['MEN'], df['WOMEN'], df['YOUTH'], df['CHILDREN'], df['SUNDAY_HOME_CHURCH']]
    bp1 = ax1.boxplot(attendance_data, labels=['Men', 'Women', 'Youth', 'Children', 'Home Church'],
                      patch_artist=True)
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6']
    for patch, color in zip(bp1['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax1.set_title('Attendance Distribution (Box Plot)', fontweight='bold')
    ax1.set_ylabel('Attendance')
    ax1.grid(True, alpha=0.3)
    
    # Financial box plots
    ax2 = axes[1]
    financial_data = [df['TITHE']/1000, df['OFFERINGS']/1000, 
                      df['EMERGENCY_COLLECTION']/1000, df['PLANNED_COLLECTION']/1000]
    bp2 = ax2.boxplot(financial_data, labels=['Tithe', 'Offerings', 'Emergency', 'Planned'],
                      patch_artist=True)
    colors2 = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']
    for patch, color in zip(bp2['boxes'], colors2):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax2.set_title('Financial Distribution (Box Plot)', fontweight='bold')
    ax2.set_ylabel('Amount (Thousands)')
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Box Plot Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/box_plots.png', dpi=150)
    plt.show()
    print("Saved: dataset1/box_plots.png")

def plot_violin_plots():
    """Violin plots for distributions"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Prepare data for violin plots
    attendance_df = pd.melt(df[['MEN', 'WOMEN', 'YOUTH', 'CHILDREN']], 
                            var_name='Category', value_name='Attendance')
    
    ax1 = axes[0]
    sns.violinplot(x='Category', y='Attendance', data=attendance_df, ax=ax1,
                   palette=['#3498db', '#e74c3c', '#2ecc71', '#f39c12'])
    ax1.set_title('Attendance Distribution (Violin Plot)', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    financial_df = pd.DataFrame({
        'Tithe': df['TITHE']/1000,
        'Offerings': df['OFFERINGS']/1000
    })
    financial_melt = pd.melt(financial_df, var_name='Type', value_name='Amount (K)')
    
    ax2 = axes[1]
    sns.violinplot(x='Type', y='Amount (K)', data=financial_melt, ax=ax2,
                   palette=['#27ae60', '#3498db'])
    ax2.set_title('Financial Distribution (Violin Plot)', fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Violin Plot Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/violin_plots.png', dpi=150)
    plt.show()
    print("Saved: dataset1/violin_plots.png")

def plot_stacked_area():
    """Stacked area charts"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Attendance stacked area
    ax1 = axes[0]
    ax1.stackplot(df['SATURDAY'], df['MEN'], df['WOMEN'], df['YOUTH'], df['CHILDREN'],
                  labels=['Men', 'Women', 'Youth', 'Children'],
                  colors=['#3498db', '#e74c3c', '#2ecc71', '#f39c12'], alpha=0.8)
    ax1.set_title('Attendance Composition Over Time', fontweight='bold')
    ax1.set_xlabel('Week')
    ax1.set_ylabel('Attendance')
    ax1.legend(loc='upper left')
    ax1.grid(True, alpha=0.3)
    
    # Income stacked area
    ax2 = axes[1]
    ax2.stackplot(df['SATURDAY'], 
                  df['TITHE']/1000, df['OFFERINGS']/1000, 
                  df['EMERGENCY_COLLECTION']/1000, df['PLANNED_COLLECTION']/1000,
                  labels=['Tithe', 'Offerings', 'Emergency', 'Planned'],
                  colors=['#27ae60', '#3498db', '#e74c3c', '#f39c12'], alpha=0.8)
    ax2.set_title('Income Composition Over Time', fontweight='bold')
    ax2.set_xlabel('Week')
    ax2.set_ylabel('Amount (Thousands)')
    ax2.legend(loc='upper left')
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Stacked Area Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/stacked_area.png', dpi=150)
    plt.show()
    print("Saved: dataset1/stacked_area.png")

def plot_pie_charts():
    """Comprehensive pie charts"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))
    
    # Attendance distribution
    ax1 = axes[0, 0]
    att_totals = [df['MEN'].sum(), df['WOMEN'].sum(), df['YOUTH'].sum(), df['CHILDREN'].sum()]
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    ax1.pie(att_totals, labels=['Men', 'Women', 'Youth', 'Children'], colors=colors,
            autopct='%1.1f%%', shadow=True, startangle=90, explode=(0, 0.05, 0, 0))
    ax1.set_title('Saturday Service Attendance', fontweight='bold')
    
    # Income distribution
    ax2 = axes[0, 1]
    inc_totals = [df['TITHE'].sum(), df['OFFERINGS'].sum(), 
                  df['EMERGENCY_COLLECTION'].sum(), df['PLANNED_COLLECTION'].sum()]
    colors2 = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']
    ax2.pie(inc_totals, labels=['Tithe', 'Offerings', 'Emergency', 'Planned'], colors=colors2,
            autopct='%1.1f%%', shadow=True, startangle=90)
    ax2.set_title('Total Income Distribution', fontweight='bold')
    
    # Adult vs Young
    ax3 = axes[1, 0]
    adult_young = [df['ADULT_ATTENDANCE'].sum(), df['YOUNG_ATTENDANCE'].sum()]
    ax3.pie(adult_young, labels=['Adults (Men+Women)', 'Young (Youth+Children)'],
            colors=['#9b59b6', '#1abc9c'], autopct='%1.1f%%', shadow=True, startangle=90,
            explode=(0.03, 0.03))
    ax3.set_title('Adult vs Young Attendance', fontweight='bold')
    
    # Regular vs Special income
    ax4 = axes[1, 1]
    reg_special = [df['REGULAR_INCOME'].sum(), df['SPECIAL_COLLECTIONS'].sum()]
    ax4.pie(reg_special, labels=['Regular (Tithe+Offerings)', 'Special Collections'],
            colors=['#27ae60', '#e74c3c'], autopct='%1.1f%%', shadow=True, startangle=90,
            explode=(0.03, 0.03))
    ax4.set_title('Regular vs Special Income', fontweight='bold')
    
    plt.suptitle('Distribution Analysis (Pie Charts)', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/pie_charts.png', dpi=150)
    plt.show()
    print("Saved: dataset1/pie_charts.png")

def plot_grouped_bar_comparison():
    """Grouped bar charts for comparisons"""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    x = range(len(df['SATURDAY']))
    width = 0.2
    
    # All demographics comparison
    ax1 = axes[0, 0]
    ax1.bar([i - 1.5*width for i in x], df['MEN'], width, label='Men', color='#3498db')
    ax1.bar([i - 0.5*width for i in x], df['WOMEN'], width, label='Women', color='#e74c3c')
    ax1.bar([i + 0.5*width for i in x], df['YOUTH'], width, label='Youth', color='#2ecc71')
    ax1.bar([i + 1.5*width for i in x], df['CHILDREN'], width, label='Children', color='#f39c12')
    ax1.set_xticks(x)
    ax1.set_xticklabels(df['SATURDAY'])
    ax1.set_title('Weekly Attendance by Category', fontweight='bold')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    
    # Financial comparison
    ax2 = axes[0, 1]
    width2 = 0.35
    ax2.bar([i - width2/2 for i in x], df['TITHE']/1000, width2, label='Tithe', color='#27ae60')
    ax2.bar([i + width2/2 for i in x], df['OFFERINGS']/1000, width2, label='Offerings', color='#3498db')
    ax2.set_xticks(x)
    ax2.set_xticklabels(df['SATURDAY'])
    ax2.set_title('Tithe vs Offerings', fontweight='bold')
    ax2.set_ylabel('Amount (Thousands)')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)
    
    # Adult vs Young attendance
    ax3 = axes[1, 0]
    ax3.bar([i - width2/2 for i in x], df['ADULT_ATTENDANCE'], width2, label='Adults', color='#9b59b6')
    ax3.bar([i + width2/2 for i in x], df['YOUNG_ATTENDANCE'], width2, label='Young', color='#1abc9c')
    ax3.set_xticks(x)
    ax3.set_xticklabels(df['SATURDAY'])
    ax3.set_title('Adult vs Young Attendance', fontweight='bold')
    ax3.legend()
    ax3.grid(axis='y', alpha=0.3)
    
    # Regular vs Total Income
    ax4 = axes[1, 1]
    ax4.bar([i - width2/2 for i in x], df['REGULAR_INCOME']/1000, width2, label='Regular', color='#27ae60')
    ax4.bar([i + width2/2 for i in x], df['TOTAL_INCOME']/1000, width2, label='Total', color='#e74c3c', alpha=0.7)
    ax4.set_xticks(x)
    ax4.set_xticklabels(df['SATURDAY'])
    ax4.set_title('Regular vs Total Income', fontweight='bold')
    ax4.set_ylabel('Amount (Thousands)')
    ax4.legend()
    ax4.grid(axis='y', alpha=0.3)
    
    plt.suptitle('Comparative Bar Charts', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/grouped_bar_comparison.png', dpi=150)
    plt.show()
    print("Saved: dataset1/grouped_bar_comparison.png")

def plot_dual_axis_trends():
    """Dual axis charts showing variable trends over time"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Attendance vs Total Income
    ax1 = axes[0, 0]
    ax1_twin = ax1.twinx()
    ax1.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', linewidth=2, label='Attendance')
    ax1_twin.plot(df['SATURDAY'], df['TOTAL_INCOME']/1000, 's-', color='#27ae60', linewidth=2, label='Income (K)')
    ax1.set_ylabel('Total Attendance', color='#9b59b6')
    ax1_twin.set_ylabel('Total Income (K)', color='#27ae60')
    ax1.set_title('Attendance vs Total Income', fontweight='bold')
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax1_twin.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax1.grid(True, alpha=0.3)
    
    # Men vs Tithe
    ax2 = axes[0, 1]
    ax2_twin = ax2.twinx()
    ax2.plot(df['SATURDAY'], df['MEN'], 'o-', color='#3498db', linewidth=2, label='Men')
    ax2_twin.plot(df['SATURDAY'], df['TITHE']/1000, 's-', color='#27ae60', linewidth=2, label='Tithe (K)')
    ax2.set_ylabel('Men Attendance', color='#3498db')
    ax2_twin.set_ylabel('Tithe (K)', color='#27ae60')
    ax2.set_title('Men vs Tithe', fontweight='bold')
    lines1, labels1 = ax2.get_legend_handles_labels()
    lines2, labels2 = ax2_twin.get_legend_handles_labels()
    ax2.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax2.grid(True, alpha=0.3)
    
    # Women vs Offerings
    ax3 = axes[1, 0]
    ax3_twin = ax3.twinx()
    ax3.plot(df['SATURDAY'], df['WOMEN'], 'o-', color='#e74c3c', linewidth=2, label='Women')
    ax3_twin.plot(df['SATURDAY'], df['OFFERINGS']/1000, 's-', color='#3498db', linewidth=2, label='Offerings (K)')
    ax3.set_ylabel('Women Attendance', color='#e74c3c')
    ax3_twin.set_ylabel('Offerings (K)', color='#3498db')
    ax3.set_title('Women vs Offerings', fontweight='bold')
    lines1, labels1 = ax3.get_legend_handles_labels()
    lines2, labels2 = ax3_twin.get_legend_handles_labels()
    ax3.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax3.grid(True, alpha=0.3)
    
    # Home Church vs Regular Income
    ax4 = axes[1, 1]
    ax4_twin = ax4.twinx()
    ax4.plot(df['SATURDAY'], df['SUNDAY_HOME_CHURCH'], 'o-', color='#9b59b6', linewidth=2, label='Home Church')
    ax4_twin.plot(df['SATURDAY'], df['REGULAR_INCOME']/1000, 's-', color='#27ae60', linewidth=2, label='Regular Income (K)')
    ax4.set_ylabel('Home Church Attendance', color='#9b59b6')
    ax4_twin.set_ylabel('Regular Income (K)', color='#27ae60')
    ax4.set_title('Home Church vs Regular Income', fontweight='bold')
    lines1, labels1 = ax4.get_legend_handles_labels()
    lines2, labels2 = ax4_twin.get_legend_handles_labels()
    ax4.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax4.grid(True, alpha=0.3)
    
    plt.suptitle('Dual Axis Trend Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/dual_axis_trends.png', dpi=150)
    plt.show()
    print("Saved: dataset1/dual_axis_trends.png")

def plot_per_capita_analysis():
    """Per capita metrics analysis"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Income per attendee trend
    ax1 = axes[0, 0]
    ax1.plot(df['SATURDAY'], df['INCOME_PER_ATTENDEE'], 'o-', color='#9b59b6', 
             linewidth=2, markersize=8)
    ax1.fill_between(df['SATURDAY'], df['INCOME_PER_ATTENDEE'], alpha=0.3, color='#9b59b6')
    ax1.axhline(df['INCOME_PER_ATTENDEE'].mean(), color='red', linestyle='--', 
                label=f'Mean: {df["INCOME_PER_ATTENDEE"].mean():.0f}')
    ax1.set_title('Income Per Attendee Over Time', fontweight='bold')
    ax1.set_ylabel('Income per Attendee')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Tithe per attendee
    ax2 = axes[0, 1]
    ax2.bar(df['SATURDAY'], df['TITHE_PER_ATTENDEE'], color='#27ae60', alpha=0.7)
    ax2.axhline(df['TITHE_PER_ATTENDEE'].mean(), color='red', linestyle='--',
                label=f'Mean: {df["TITHE_PER_ATTENDEE"].mean():.0f}')
    ax2.set_title('Tithe Per Attendee', fontweight='bold')
    ax2.set_ylabel('Tithe per Attendee')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Regular income per adult
    ax3 = axes[1, 0]
    ax3.bar(df['SATURDAY'], df['REGULAR_INCOME_PER_ADULT'], color='#3498db', alpha=0.7)
    ax3.axhline(df['REGULAR_INCOME_PER_ADULT'].mean(), color='red', linestyle='--',
                label=f'Mean: {df["REGULAR_INCOME_PER_ADULT"].mean():.0f}')
    ax3.set_title('Regular Income Per Adult', fontweight='bold')
    ax3.set_ylabel('Regular Income per Adult')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # All per capita metrics comparison
    ax4 = axes[1, 1]
    x = range(len(df['SATURDAY']))
    width = 0.25
    ax4.bar([i - width for i in x], df['INCOME_PER_ATTENDEE']/100, width, 
            label='Total Income/Attendee (÷100)', color='#9b59b6')
    ax4.bar(x, df['TITHE_PER_ATTENDEE'], width, label='Tithe/Attendee', color='#27ae60')
    ax4.bar([i + width for i in x], df['OFFERINGS_PER_ATTENDEE'], width, 
            label='Offerings/Attendee', color='#3498db')
    ax4.set_xticks(x)
    ax4.set_xticklabels(df['SATURDAY'])
    ax4.set_title('Per Capita Metrics Comparison', fontweight='bold')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.suptitle('Per Capita Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/per_capita_analysis.png', dpi=150)
    plt.show()
    print("Saved: dataset1/per_capita_analysis.png")

def plot_ratio_analysis():
    """Ratio metrics analysis"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Men:Women ratio
    ax1 = axes[0, 0]
    ax1.plot(df['SATURDAY'], df['MEN_WOMEN_RATIO'], 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax1.axhline(1.0, color='gray', linestyle='--', alpha=0.7, label='1:1 ratio')
    ax1.axhline(df['MEN_WOMEN_RATIO'].mean(), color='red', linestyle='--', 
                label=f'Mean: {df["MEN_WOMEN_RATIO"].mean():.3f}')
    ax1.set_title('Men to Women Ratio', fontweight='bold')
    ax1.set_ylabel('Ratio')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Adult:Young ratio
    ax2 = axes[0, 1]
    ax2.plot(df['SATURDAY'], df['ADULT_YOUNG_RATIO'], 'o-', color='#3498db', linewidth=2, markersize=8)
    ax2.axhline(df['ADULT_YOUNG_RATIO'].mean(), color='red', linestyle='--',
                label=f'Mean: {df["ADULT_YOUNG_RATIO"].mean():.3f}')
    ax2.set_title('Adult to Young Ratio', fontweight='bold')
    ax2.set_ylabel('Ratio')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Tithe:Offerings ratio
    ax3 = axes[1, 0]
    ax3.plot(df['SATURDAY'], df['TITHE_OFFERINGS_RATIO'], 'o-', color='#27ae60', linewidth=2, markersize=8)
    ax3.axhline(1.0, color='gray', linestyle='--', alpha=0.7, label='1:1 ratio')
    ax3.axhline(df['TITHE_OFFERINGS_RATIO'].mean(), color='red', linestyle='--',
                label=f'Mean: {df["TITHE_OFFERINGS_RATIO"].mean():.3f}')
    ax3.set_title('Tithe to Offerings Ratio', fontweight='bold')
    ax3.set_ylabel('Ratio')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # All ratios comparison
    ax4 = axes[1, 1]
    ax4.plot(df['SATURDAY'], df['MEN_WOMEN_RATIO'], 'o-', label='Men:Women', linewidth=2)
    ax4.plot(df['SATURDAY'], df['ADULT_YOUNG_RATIO'], 's-', label='Adult:Young', linewidth=2)
    ax4.plot(df['SATURDAY'], df['TITHE_OFFERINGS_RATIO'], '^-', label='Tithe:Offerings', linewidth=2)
    ax4.axhline(1.0, color='gray', linestyle='--', alpha=0.7)
    ax4.set_title('All Ratios Over Time', fontweight='bold')
    ax4.set_ylabel('Ratio')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.suptitle('Ratio Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/ratio_analysis.png', dpi=150)
    plt.show()
    print("Saved: dataset1/ratio_analysis.png")

def plot_percentage_analysis():
    """Percentage composition analysis"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Attendance percentage stacked
    ax1 = axes[0, 0]
    ax1.stackplot(df['SATURDAY'], df['MEN_PCT'], df['WOMEN_PCT'], 
                  df['YOUTH_PCT'], df['CHILDREN_PCT'],
                  labels=['Men %', 'Women %', 'Youth %', 'Children %'],
                  colors=['#3498db', '#e74c3c', '#2ecc71', '#f39c12'], alpha=0.8)
    ax1.set_title('Attendance Composition (%)', fontweight='bold')
    ax1.set_ylabel('Percentage')
    ax1.legend(loc='center left', bbox_to_anchor=(1, 0.5))
    ax1.set_ylim(0, 100)
    ax1.grid(True, alpha=0.3)
    
    # Individual percentages line
    ax2 = axes[0, 1]
    ax2.plot(df['SATURDAY'], df['MEN_PCT'], 'o-', label='Men %', color='#3498db')
    ax2.plot(df['SATURDAY'], df['WOMEN_PCT'], 's-', label='Women %', color='#e74c3c')
    ax2.plot(df['SATURDAY'], df['YOUTH_PCT'], '^-', label='Youth %', color='#2ecc71')
    ax2.plot(df['SATURDAY'], df['CHILDREN_PCT'], 'd-', label='Children %', color='#f39c12')
    ax2.set_title('Individual Percentage Trends', fontweight='bold')
    ax2.set_ylabel('Percentage')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # Average percentages bar
    ax3 = axes[1, 0]
    categories = ['Men', 'Women', 'Youth', 'Children']
    avg_pcts = [df['MEN_PCT'].mean(), df['WOMEN_PCT'].mean(), 
                df['YOUTH_PCT'].mean(), df['CHILDREN_PCT'].mean()]
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    bars = ax3.bar(categories, avg_pcts, color=colors, alpha=0.7)
    for bar, pct in zip(bars, avg_pcts):
        ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5, 
                 f'{pct:.1f}%', ha='center', fontsize=10)
    ax3.set_title('Average Percentage by Category', fontweight='bold')
    ax3.set_ylabel('Average Percentage')
    ax3.grid(True, alpha=0.3)
    
    # Percentage variability
    ax4 = axes[1, 1]
    pct_cols = ['MEN_PCT', 'WOMEN_PCT', 'YOUTH_PCT', 'CHILDREN_PCT']
    pct_data = [df[col] for col in pct_cols]
    bp = ax4.boxplot(pct_data, labels=['Men', 'Women', 'Youth', 'Children'], patch_artist=True)
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax4.set_title('Percentage Variability', fontweight='bold')
    ax4.set_ylabel('Percentage')
    ax4.grid(True, alpha=0.3)
    
    plt.suptitle('Percentage Composition Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset1/percentage_analysis.png', dpi=150)
    plt.show()
    print("Saved: dataset1/percentage_analysis.png")

def plot_comprehensive_dashboard():
    """Create comprehensive summary dashboard"""
    fig = plt.figure(figsize=(20, 16))
    
    # Define grid
    gs = fig.add_gridspec(4, 4, hspace=0.3, wspace=0.3)
    
    # 1. Attendance trend (top left, spans 2 cols)
    ax1 = fig.add_subplot(gs[0, 0:2])
    ax1.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', linewidth=2)
    z = np.polyfit(range(len(df)), df['TOTAL_ATTENDANCE'], 1)
    p = np.poly1d(z)
    ax1.plot(df['SATURDAY'], p(range(len(df))), '--', color='red', linewidth=2)
    ax1.set_title('Total Attendance Trend', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    # 2. Income trend (top right, spans 2 cols)
    ax2 = fig.add_subplot(gs[0, 2:4])
    ax2.plot(df['SATURDAY'], df['TOTAL_INCOME']/1000, 'o-', color='#27ae60', linewidth=2)
    z = np.polyfit(range(len(df)), df['TOTAL_INCOME']/1000, 1)
    p = np.poly1d(z)
    ax2.plot(df['SATURDAY'], p(range(len(df))), '--', color='red', linewidth=2)
    ax2.set_title('Total Income Trend (K)', fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    # 3. Attendance pie
    ax3 = fig.add_subplot(gs[1, 0])
    att_totals = [df['MEN'].sum(), df['WOMEN'].sum(), df['YOUTH'].sum(), df['CHILDREN'].sum()]
    ax3.pie(att_totals, labels=['Men', 'Women', 'Youth', 'Children'],
            colors=['#3498db', '#e74c3c', '#2ecc71', '#f39c12'],
            autopct='%1.0f%%', startangle=90)
    ax3.set_title('Attendance Dist.', fontweight='bold')
    
    # 4. Income pie
    ax4 = fig.add_subplot(gs[1, 1])
    inc_totals = [df['TITHE'].sum(), df['OFFERINGS'].sum(), 
                  df['EMERGENCY_COLLECTION'].sum(), df['PLANNED_COLLECTION'].sum()]
    ax4.pie(inc_totals, labels=['Tithe', 'Off.', 'Emerg.', 'Plan.'],
            colors=['#27ae60', '#3498db', '#e74c3c', '#f39c12'],
            autopct='%1.0f%%', startangle=90)
    ax4.set_title('Income Dist.', fontweight='bold')
    
    # 5. Correlation scatter
    ax5 = fig.add_subplot(gs[1, 2])
    ax5.scatter(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME']/1000, c='#9b59b6', s=80, alpha=0.7)
    z = np.polyfit(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME']/1000, 1)
    p = np.poly1d(z)
    x_line = np.linspace(df['TOTAL_ATTENDANCE'].min(), df['TOTAL_ATTENDANCE'].max(), 100)
    ax5.plot(x_line, p(x_line), '--', color='red', linewidth=2)
    r, _ = pearsonr(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME'])
    ax5.set_title(f'Att. vs Income (r={r:.2f})', fontweight='bold')
    ax5.grid(True, alpha=0.3)
    
    # 6. Growth rates
    ax6 = fig.add_subplot(gs[1, 3])
    colors_growth = ['#27ae60' if x >= 0 else '#e74c3c' for x in df['ATTENDANCE_GROWTH'].fillna(0)]
    ax6.bar(range(len(df)), df['ATTENDANCE_GROWTH'].fillna(0), color=colors_growth)
    ax6.axhline(0, color='black', linewidth=0.5)
    ax6.set_title('Weekly Growth %', fontweight='bold')
    ax6.set_xticks(range(len(df)))
    ax6.set_xticklabels([f'W{i+1}' for i in range(len(df))], fontsize=8)
    
    # 7. Demographics bar (spans 2 cols)
    ax7 = fig.add_subplot(gs[2, 0:2])
    x = range(len(df['SATURDAY']))
    width = 0.2
    ax7.bar([i - 1.5*width for i in x], df['MEN'], width, label='Men', color='#3498db')
    ax7.bar([i - 0.5*width for i in x], df['WOMEN'], width, label='Women', color='#e74c3c')
    ax7.bar([i + 0.5*width for i in x], df['YOUTH'], width, label='Youth', color='#2ecc71')
    ax7.bar([i + 1.5*width for i in x], df['CHILDREN'], width, label='Children', color='#f39c12')
    ax7.set_xticks(x)
    ax7.set_xticklabels(df['SATURDAY'], fontsize=8)
    ax7.set_title('Attendance by Category', fontweight='bold')
    ax7.legend(fontsize=8)
    ax7.grid(axis='y', alpha=0.3)
    
    # 8. Financial bar (spans 2 cols)
    ax8 = fig.add_subplot(gs[2, 2:4])
    width2 = 0.35
    ax8.bar([i - width2/2 for i in x], df['TITHE']/1000, width2, label='Tithe', color='#27ae60')
    ax8.bar([i + width2/2 for i in x], df['OFFERINGS']/1000, width2, label='Offerings', color='#3498db')
    ax8.set_xticks(x)
    ax8.set_xticklabels(df['SATURDAY'], fontsize=8)
    ax8.set_title('Tithe vs Offerings (K)', fontweight='bold')
    ax8.legend(fontsize=8)
    ax8.grid(axis='y', alpha=0.3)
    
    # 9. Statistics panel (spans 4 cols)
    ax9 = fig.add_subplot(gs[3, :])
    ax9.axis('off')
    
    total_att = df['TOTAL_ATTENDANCE'].sum()
    total_inc = df['TOTAL_INCOME'].sum()
    r_corr, _ = pearsonr(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME'])
    
    stats_text = f"""
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                    COMPREHENSIVE CHURCH STATISTICS SUMMARY                                            ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║  ATTENDANCE                              │  FINANCIAL                               │  CORRELATIONS & RATIOS          ║
║  ────────────────────────────────────────┼──────────────────────────────────────────┼─────────────────────────────────║
║  Total Attendance: {total_att:,}           │  Total Income: {total_inc:,}            │  Attendance-Income: r={r_corr:.3f}   ║
║  Men Total: {df['MEN'].sum():,} ({df['MEN'].sum()/total_att*100:.1f}%)          │  Total Tithe: {df['TITHE'].sum():,}           │  Men:Women Ratio: {df['MEN'].sum()/df['WOMEN'].sum():.3f}       ║
║  Women Total: {df['WOMEN'].sum():,} ({df['WOMEN'].sum()/total_att*100:.1f}%)       │  Total Offerings: {df['OFFERINGS'].sum():,}        │  Adult:Young Ratio: {df['ADULT_ATTENDANCE'].sum()/df['YOUNG_ATTENDANCE'].sum():.3f}     ║
║  Youth Total: {df['YOUTH'].sum():,} ({df['YOUTH'].sum()/total_att*100:.1f}%)        │  Emergency: {df['EMERGENCY_COLLECTION'].sum():,}              │  Tithe:Offerings: {df['TITHE'].sum()/df['OFFERINGS'].sum():.3f}        ║
║  Children Total: {df['CHILDREN'].sum():,} ({df['CHILDREN'].sum()/total_att*100:.1f}%)     │  Planned: {df['PLANNED_COLLECTION'].sum():,}               │  Avg Income/Attendee: {df['INCOME_PER_ATTENDEE'].mean():.0f}   ║
║  Avg Weekly: {df['TOTAL_ATTENDANCE'].mean():,.0f}                 │  Avg Weekly: {df['TOTAL_INCOME'].mean():,.0f}               │  Avg Tithe/Attendee: {df['TITHE_PER_ATTENDEE'].mean():.0f}     ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
"""
    ax9.text(0.02, 0.5, stats_text, transform=ax9.transAxes, fontsize=9,
             verticalalignment='center', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))
    
    plt.suptitle('CHURCH DATA COMPREHENSIVE DASHBOARD', fontsize=16, fontweight='bold', y=0.98)
    plt.savefig('church_analysis/dataset1/comprehensive_dashboard.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset1/comprehensive_dashboard.png")

def save_all_tables():
    """Save all computed data tables to CSV"""
    
    # Main data with all computations
    df.to_csv('church_analysis/dataset1/complete_data.csv', index=False)
    print("Saved: dataset1/complete_data.csv")
    
    # Correlation matrix
    corr_vars = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'SUNDAY_HOME_CHURCH',
                 'TOTAL_ATTENDANCE', 'TITHE', 'OFFERINGS', 'TOTAL_INCOME']
    corr_matrix = df[corr_vars].corr()
    corr_matrix.to_csv('church_analysis/dataset1/correlation_matrix.csv')
    print("Saved: dataset1/correlation_matrix.csv")
    
    # Summary statistics
    create_statistics_table()
    
    # Per capita metrics
    per_capita_df = df[['SATURDAY', 'INCOME_PER_ATTENDEE', 'TITHE_PER_ATTENDEE', 
                        'OFFERINGS_PER_ATTENDEE', 'REGULAR_INCOME_PER_ADULT']].copy()
    per_capita_df.to_csv('church_analysis/dataset1/per_capita_metrics.csv', index=False)
    print("Saved: dataset1/per_capita_metrics.csv")
    
    # Ratios
    ratios_df = df[['SATURDAY', 'MEN_WOMEN_RATIO', 'ADULT_YOUNG_RATIO', 
                    'TITHE_OFFERINGS_RATIO']].copy()
    ratios_df.to_csv('church_analysis/dataset1/ratio_metrics.csv', index=False)
    print("Saved: dataset1/ratio_metrics.csv")
    
    # Growth metrics
    growth_df = df[['SATURDAY', 'ATTENDANCE_GROWTH', 'INCOME_GROWTH', 'TITHE_GROWTH']].copy()
    growth_df.to_csv('church_analysis/dataset1/growth_metrics.csv', index=False)
    print("Saved: dataset1/growth_metrics.csv")
    
    # Percentages
    pct_df = df[['SATURDAY', 'MEN_PCT', 'WOMEN_PCT', 'YOUTH_PCT', 'CHILDREN_PCT']].copy()
    pct_df.to_csv('church_analysis/dataset1/percentage_composition.csv', index=False)
    print("Saved: dataset1/percentage_composition.csv")

# ============================================
# MAIN EXECUTION
# ============================================

def generate_all():
    """Generate all statistics and graphs"""
    print("\n" + "="*80)
    print("CHURCH DATA COMPLETE ANALYSIS")
    print("Generating all statistics, tables, and graphs...")
    print("="*80)
    
    # Compute and display statistics
    compute_all_statistics()
    
    # Save all tables
    print("\n" + "-"*80)
    print("SAVING DATA TABLES")
    print("-"*80)
    save_all_tables()
    
    # Generate all graphs
    print("\n" + "-"*80)
    print("GENERATING GRAPHS")
    print("-"*80)
    
    plot_attendance_overview()
    plot_demographics_weekly()
    plot_attendance_income_trends()
    plot_demographic_comparison()
    plot_financial_weekly()
    plot_home_church_comparison()
    plot_time_series_all()
    plot_distribution_analysis()
    plot_box_plots()
    plot_violin_plots()
    plot_stacked_area()
    plot_pie_charts()
    plot_grouped_bar_comparison()
    plot_dual_axis_trends()
    plot_per_capita_analysis()
    plot_ratio_analysis()
    plot_percentage_analysis()
    plot_comprehensive_dashboard()
    
    print("\n" + "="*80)
    print("DATASET 1 ANALYSIS COMPLETE!")
    print("="*80)
    print(f"\nAll Dataset 1 files saved to: church_analysis/dataset1/")

# ===================================================================
# DATASET 2 ANALYSIS FUNCTIONS
# ===================================================================

def compute_ds2_statistics():
    """Compute and print all statistics for Dataset 2"""
    print("\n" + "="*80)
    print("DATASET 2 — JAN/FEB 2026 STATISTICAL ANALYSIS")
    print("="*80)

    numeric_cols2 = ['MEN','WOMEN','YOUTH','CHILDREN','TOTAL_ATTENDANCE',
                     'HOME_CHURCH','TITHE','OFFERINGS','TOTAL_INCOME']

    print("\n--- Descriptive Statistics ---")
    print(df2[numeric_cols2].describe().round(2).to_string())

    print("\n--- Additional Measures ---")
    for col in numeric_cols2:
        print(f"\n{col}:")
        print(f"  Sum:        {df2[col].sum():,.2f}")
        print(f"  Mean:       {df2[col].mean():,.2f}")
        print(f"  Median:     {df2[col].median():,.2f}")
        print(f"  Std Dev:    {df2[col].std():,.2f}")
        print(f"  Min:        {df2[col].min():,.2f}")
        print(f"  Max:        {df2[col].max():,.2f}")
        print(f"  Range:      {df2[col].max() - df2[col].min():,.2f}")
        cv = (df2[col].std() / df2[col].mean()) * 100 if df2[col].mean() != 0 else 0
        print(f"  CV (%):     {cv:.2f}")
        print(f"  Skewness:   {df2[col].skew():.4f}")

    print("\n--- Target Achievement (Average across weeks) ---")
    target_cols = {
        'MEN': 'MEN_TARGET_PCT', 'WOMEN': 'WOMEN_TARGET_PCT', 'YOUTH': 'YOUTH_TARGET_PCT',
        'CHILDREN': 'CHILDREN_TARGET_PCT', 'TOTAL_ATTENDANCE': 'TOTAL_ATT_TARGET_PCT',
        'HOME_CHURCH': 'HOME_CHURCH_TARGET_PCT', 'TITHE': 'TITHE_TARGET_PCT',
        'OFFERINGS': 'OFFERINGS_TARGET_PCT'
    }
    for metric, pct_col in target_cols.items():
        avg_pct = df2[pct_col].mean()
        target = targets2[metric]
        actual_avg = df2[metric].mean()
        gap = actual_avg - target
        print(f"  {metric:<20}: Target={target:>12,.0f}  Avg Actual={actual_avg:>10,.0f}  "
              f"Achievement={avg_pct:>6.1f}%  Gap={gap:>10,.0f}")

    print("\n--- Pearson Correlations (Dataset 2) ---")
    pairs2 = [
        ('TOTAL_ATTENDANCE','TITHE'), ('TOTAL_ATTENDANCE','OFFERINGS'),
        ('TOTAL_ATTENDANCE','TOTAL_INCOME'), ('MEN','TITHE'), ('WOMEN','TITHE'),
        ('YOUTH','OFFERINGS'), ('CHILDREN','OFFERINGS'), ('HOME_CHURCH','TITHE'),
        ('HOME_CHURCH','TOTAL_ATTENDANCE'), ('TITHE','OFFERINGS'),
    ]
    for v1, v2 in pairs2:
        r, p = pearsonr(df2[v1], df2[v2])
        sig = "***" if p < 0.001 else "**" if p < 0.01 else "*" if p < 0.05 else ""
        print(f"  {v1} vs {v2}: r={r:.4f}, p={p:.4f} {sig}")

    print("\n--- Linear Trend Analysis (Dataset 2) ---")
    for var in ['TOTAL_ATTENDANCE','TITHE','OFFERINGS','TOTAL_INCOME']:
        slope, intercept, r_val, p_val, _ = stats.linregress(df2['WEEK'], df2[var])
        direction = 'Increasing' if slope > 0 else 'Decreasing'
        print(f"  {var}: slope={slope:,.2f}/week, R²={r_val**2:.4f}, {direction}")

def ds2_plot_correlation_heatmap():
    """Dataset 2 correlation heatmap"""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    corr_vars2 = ['MEN','WOMEN','YOUTH','CHILDREN','HOME_CHURCH',
                  'TOTAL_ATTENDANCE','TITHE','OFFERINGS','TOTAL_INCOME']
    corr2 = df2[corr_vars2].corr()

    sns.heatmap(corr2, annot=True, cmap='RdYlBu_r', center=0, fmt='.2f',
                linewidths=0.5, ax=axes[0], vmin=-1, vmax=1, annot_kws={'size': 9})
    axes[0].set_title('DS2 Correlation Matrix', fontsize=13, fontweight='bold')
    axes[0].tick_params(axis='x', rotation=45)

    # Target achievement heatmap
    tgt_data = pd.DataFrame({
        'Men': df2['MEN_TARGET_PCT'], 'Women': df2['WOMEN_TARGET_PCT'],
        'Youth': df2['YOUTH_TARGET_PCT'], 'Children': df2['CHILDREN_TARGET_PCT'],
        'Total Att': df2['TOTAL_ATT_TARGET_PCT'], 'Home Ch': df2['HOME_CHURCH_TARGET_PCT'],
        'Tithe': df2['TITHE_TARGET_PCT'], 'Offerings': df2['OFFERINGS_TARGET_PCT'],
    }, index=df2['DATE'])
    sns.heatmap(tgt_data, annot=True, cmap='RdYlGn', center=50, fmt='.1f',
                linewidths=0.5, ax=axes[1], annot_kws={'size': 8})
    axes[1].set_title('DS2 Target Achievement (%) per Week', fontsize=13, fontweight='bold')
    axes[1].tick_params(axis='x', rotation=45)
    axes[1].tick_params(axis='y', rotation=0)

    plt.suptitle('Dataset 2 — Correlation & Target Heatmaps', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/correlation_target_heatmaps.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/correlation_target_heatmaps.png")

def ds2_plot_attendance_trends():
    """Dataset 2 attendance trends and correlations"""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    x = df2['DATE']

    # All demographics trend
    ax1 = axes[0, 0]
    for col, color, marker in zip(['MEN','WOMEN','YOUTH','CHILDREN'],
                                   ['#3498db','#e74c3c','#2ecc71','#f39c12'],
                                   ['o','s','^','d']):
        ax1.plot(x, df2[col], f'{marker}-', color=color, label=col.title(), linewidth=2)
    ax1.set_title('Demographic Attendance Trends', fontweight='bold')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    ax1.tick_params(axis='x', rotation=20)

    # Total attendance vs targets
    ax2 = axes[0, 1]
    ax2.bar(x, df2['TOTAL_ATTENDANCE'], color='#9b59b6', alpha=0.7, label='Actual')
    ax2.axhline(targets2['TOTAL_ATTENDANCE'], color='red', linestyle='--', linewidth=2, label=f"Target: {targets2['TOTAL_ATTENDANCE']:,}")
    ax2.set_title('Total Attendance vs Target', fontweight='bold')
    ax2.legend(fontsize=8)
    ax2.grid(axis='y', alpha=0.3)
    ax2.tick_params(axis='x', rotation=20)

    # Home church trend
    ax3 = axes[0, 2]
    ax3.plot(x, df2['HOME_CHURCH'], 'o-', color='#1abc9c', linewidth=2, markersize=8)
    ax3.axhline(targets2['HOME_CHURCH'], color='red', linestyle='--', linewidth=2, label=f"Target: {targets2['HOME_CHURCH']:,}")
    ax3.fill_between(range(len(df2)), df2['HOME_CHURCH'], alpha=0.3, color='#1abc9c')
    ax3.set_xticks(range(len(df2)))
    ax3.set_xticklabels(x, rotation=20, fontsize=8)
    ax3.set_title('Home Church vs Target', fontweight='bold')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Men vs Women scatter
    ax4 = axes[1, 0]
    ax4.scatter(df2['MEN'], df2['WOMEN'], c=['#3498db','#e74c3c','#2ecc71','#f39c12'], s=150, zorder=5)
    for i, row in df2.iterrows():
        ax4.annotate(row['DATE'], (row['MEN'], row['WOMEN']), fontsize=8, ha='left')
    z = np.polyfit(df2['MEN'], df2['WOMEN'], 1)
    p = np.poly1d(z)
    xl = np.linspace(df2['MEN'].min(), df2['MEN'].max(), 100)
    ax4.plot(xl, p(xl), '--', color='gray', linewidth=2)
    r, pv = pearsonr(df2['MEN'], df2['WOMEN'])
    ax4.text(0.05, 0.95, f'r={r:.3f}', transform=ax4.transAxes, fontsize=10,
             va='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax4.set_xlabel('Men')
    ax4.set_ylabel('Women')
    ax4.set_title('Men vs Women Correlation', fontweight='bold')
    ax4.grid(True, alpha=0.3)

    # Adult vs Young scatter
    ax5 = axes[1, 1]
    ax5.scatter(df2['ADULT_ATTENDANCE'], df2['YOUNG_ATTENDANCE'], c='#9b59b6', s=150)
    for i, row in df2.iterrows():
        ax5.annotate(row['DATE'], (row['ADULT_ATTENDANCE'], row['YOUNG_ATTENDANCE']), fontsize=8)
    z = np.polyfit(df2['ADULT_ATTENDANCE'], df2['YOUNG_ATTENDANCE'], 1)
    p = np.poly1d(z)
    xl = np.linspace(df2['ADULT_ATTENDANCE'].min(), df2['ADULT_ATTENDANCE'].max(), 100)
    ax5.plot(xl, p(xl), '--', color='gray', linewidth=2)
    r, pv = pearsonr(df2['ADULT_ATTENDANCE'], df2['YOUNG_ATTENDANCE'])
    ax5.text(0.05, 0.95, f'r={r:.3f}', transform=ax5.transAxes, fontsize=10,
             va='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax5.set_xlabel('Adults (Men+Women)')
    ax5.set_ylabel('Young (Youth+Children)')
    ax5.set_title('Adult vs Young Correlation', fontweight='bold')
    ax5.grid(True, alpha=0.3)

    # Attendance percentage stacked
    ax6 = axes[1, 2]
    ax6.stackplot(x, df2['MEN_PCT'], df2['WOMEN_PCT'], df2['YOUTH_PCT'], df2['CHILDREN_PCT'],
                  labels=['Men%','Women%','Youth%','Children%'],
                  colors=['#3498db','#e74c3c','#2ecc71','#f39c12'], alpha=0.85)
    ax6.set_title('Attendance Composition %', fontweight='bold')
    ax6.set_ylim(0, 100)
    ax6.legend(fontsize=8, loc='lower right')
    ax6.grid(True, alpha=0.3)
    ax6.tick_params(axis='x', rotation=20)

    plt.suptitle('Dataset 2 — Attendance Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/attendance_trends.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/attendance_trends.png")

def ds2_plot_financial_analysis():
    """Dataset 2 financial analysis with targets"""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    x = df2['DATE']

    # Tithe trend vs target
    ax1 = axes[0, 0]
    ax1.bar(x, df2['TITHE']/1000, color='#27ae60', alpha=0.7, label='Actual')
    ax1.axhline(targets2['TITHE']/1000, color='red', linestyle='--', linewidth=2,
                label=f"Target: {targets2['TITHE']/1000:.0f}K")
    ax1.set_title('Tithe vs Target', fontweight='bold')
    ax1.set_ylabel('Amount (K)')
    ax1.legend(fontsize=8)
    ax1.grid(axis='y', alpha=0.3)
    ax1.tick_params(axis='x', rotation=20)

    # Offerings trend vs target
    ax2 = axes[0, 1]
    ax2.bar(x, df2['OFFERINGS']/1000, color='#3498db', alpha=0.7, label='Actual')
    ax2.axhline(targets2['OFFERINGS']/1000, color='red', linestyle='--', linewidth=2,
                label=f"Target: {targets2['OFFERINGS']/1000:.0f}K")
    ax2.set_title('Offerings vs Target', fontweight='bold')
    ax2.set_ylabel('Amount (K)')
    ax2.legend(fontsize=8)
    ax2.grid(axis='y', alpha=0.3)
    ax2.tick_params(axis='x', rotation=20)

    # Total income trend
    ax3 = axes[0, 2]
    ax3.plot(x, df2['TOTAL_INCOME']/1000, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax3.fill_between(range(len(df2)), df2['TOTAL_INCOME']/1000, alpha=0.3, color='#e74c3c')
    ax3.set_xticks(range(len(df2)))
    ax3.set_xticklabels(x, rotation=20, fontsize=8)
    ax3.set_title('Total Income Trend', fontweight='bold')
    ax3.set_ylabel('Total Income (K)')
    ax3.grid(True, alpha=0.3)

    # Tithe vs Offerings scatter
    ax4 = axes[1, 0]
    ax4.scatter(df2['TITHE']/1000, df2['OFFERINGS']/1000,
                c=['#27ae60','#3498db','#e74c3c','#f39c12'], s=150, zorder=5)
    for i, row in df2.iterrows():
        ax4.annotate(row['DATE'], (row['TITHE']/1000, row['OFFERINGS']/1000), fontsize=8)
    z = np.polyfit(df2['TITHE'], df2['OFFERINGS'], 1)
    p = np.poly1d(z)
    xl = np.linspace(df2['TITHE'].min(), df2['TITHE'].max(), 100)
    ax4.plot(xl/1000, p(xl)/1000, '--', color='gray', linewidth=2)
    r, pv = pearsonr(df2['TITHE'], df2['OFFERINGS'])
    ax4.text(0.05, 0.95, f'r={r:.3f}', transform=ax4.transAxes, fontsize=10,
             va='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax4.set_xlabel('Tithe (K)')
    ax4.set_ylabel('Offerings (K)')
    ax4.set_title('Tithe vs Offerings Correlation', fontweight='bold')
    ax4.grid(True, alpha=0.3)

    # Total attendance vs Total income
    ax5 = axes[1, 1]
    ax5.scatter(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME']/1000,
                c=['#9b59b6','#1abc9c','#e67e22','#8e44ad'], s=150, zorder=5)
    for i, row in df2.iterrows():
        ax5.annotate(row['DATE'], (row['TOTAL_ATTENDANCE'], row['TOTAL_INCOME']/1000), fontsize=8)
    z = np.polyfit(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME']/1000, 1)
    p = np.poly1d(z)
    xl = np.linspace(df2['TOTAL_ATTENDANCE'].min(), df2['TOTAL_ATTENDANCE'].max(), 100)
    ax5.plot(xl, p(xl), '--', color='gray', linewidth=2)
    r, pv = pearsonr(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME'])
    ax5.text(0.05, 0.95, f'r={r:.3f}', transform=ax5.transAxes, fontsize=10,
             va='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax5.set_xlabel('Total Attendance')
    ax5.set_ylabel('Total Income (K)')
    ax5.set_title('Attendance vs Income Correlation', fontweight='bold')
    ax5.grid(True, alpha=0.3)

    # Income per attendee
    ax6 = axes[1, 2]
    ax6.bar(x, df2['INCOME_PER_ATTENDEE'], color='#9b59b6', alpha=0.7)
    ax6.axhline(df2['INCOME_PER_ATTENDEE'].mean(), color='red', linestyle='--',
                label=f"Mean: {df2['INCOME_PER_ATTENDEE'].mean():.0f}")
    ax6.set_title('Income Per Attendee', fontweight='bold')
    ax6.legend(fontsize=8)
    ax6.grid(axis='y', alpha=0.3)
    ax6.tick_params(axis='x', rotation=20)

    plt.suptitle('Dataset 2 — Financial Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/financial_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/financial_analysis.png")

def ds2_plot_target_gauge():
    """Target achievement radar and gauge chart"""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Target achievement bar chart per week
    target_map = {
        'Men': 'MEN_TARGET_PCT', 'Women': 'WOMEN_TARGET_PCT', 'Youth': 'YOUTH_TARGET_PCT',
        'Children': 'CHILDREN_TARGET_PCT', 'Total Att': 'TOTAL_ATT_TARGET_PCT',
        'Home Ch': 'HOME_CHURCH_TARGET_PCT', 'Tithe': 'TITHE_TARGET_PCT',
        'Offerings': 'OFFERINGS_TARGET_PCT'
    }
    ax = axes[0]
    x_pos = np.arange(len(target_map))
    width = 0.2
    colors_w = ['#3498db','#e74c3c','#2ecc71','#f39c12']
    for i, (date, color) in enumerate(zip(df2['DATE'], colors_w)):
        vals = [df2.loc[df2['DATE'] == date, col].values[0] for col in target_map.values()]
        ax.bar(x_pos + i * width, vals, width, label=date, color=color, alpha=0.8)
    ax.axhline(100, color='black', linestyle='--', linewidth=1.5, label='100% Target')
    ax.set_xticks(x_pos + width * 1.5)
    ax.set_xticklabels(list(target_map.keys()), rotation=30, ha='right', fontsize=9)
    ax.set_ylabel('Achievement (%)')
    ax.set_title('Target Achievement % per Week', fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(axis='y', alpha=0.3)

    # Overall average achievement
    ax2 = axes[1]
    avg_achievements = [df2[col].mean() for col in target_map.values()]
    bar_colors = ['#27ae60' if v >= 100 else '#e74c3c' if v < 50 else '#f39c12' for v in avg_achievements]
    bars = ax2.barh(list(target_map.keys()), avg_achievements, color=bar_colors, alpha=0.8)
    ax2.axvline(100, color='black', linestyle='--', linewidth=1.5, label='100% Target')
    for bar, val in zip(bars, avg_achievements):
        ax2.text(val + 0.5, bar.get_y() + bar.get_height()/2, f'{val:.1f}%',
                 va='center', fontsize=9)
    ax2.set_xlabel('Average Achievement (%)')
    ax2.set_title('Overall Average Target Achievement', fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(axis='x', alpha=0.3)

    plt.suptitle('Dataset 2 — Target Achievement Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/target_achievement.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/target_achievement.png")

def ds2_plot_correlation_scatter_grid():
    """Dataset 2 all pairwise scatter plots with regression"""
    key_vars2 = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'TITHE', 'OFFERINGS']
    n = len(key_vars2)
    fig, axes = plt.subplots(n, n, figsize=(15, 15))

    for i, v1 in enumerate(key_vars2):
        for j, v2 in enumerate(key_vars2):
            ax = axes[i, j]
            if i == j:
                ax.hist(df2[v1], bins=4, color='#9b59b6', alpha=0.7)
                ax.set_xlabel(v1, fontsize=8)
            else:
                ax.scatter(df2[v2], df2[v1], c='#3498db', s=60, alpha=0.7)
                z = np.polyfit(df2[v2], df2[v1], 1)
                p = np.poly1d(z)
                xl = np.linspace(df2[v2].min(), df2[v2].max(), 50)
                ax.plot(xl, p(xl), '--', color='red', linewidth=1.5)
                r, _ = pearsonr(df2[v1], df2[v2])
                ax.text(0.05, 0.95, f'r={r:.2f}', transform=ax.transAxes, fontsize=7,
                        va='top', bbox=dict(facecolor='white', alpha=0.6))
            if j == 0:
                ax.set_ylabel(v1, fontsize=8)
            if i == n - 1:
                ax.set_xlabel(v2, fontsize=8)
            ax.tick_params(labelsize=6)

    plt.suptitle('Dataset 2 — Full Pairwise Scatter Matrix', fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/pairwise_scatter.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/pairwise_scatter.png")

def ds2_plot_ratios():
    """Dataset 2 ratio analysis"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    x = df2['DATE']

    ax1 = axes[0, 0]
    ax1.plot(x, df2['MEN_WOMEN_RATIO'], 'o-', color='#9b59b6', linewidth=2, markersize=8)
    ax1.axhline(1.0, color='gray', linestyle='--', alpha=0.7)
    ax1.axhline(df2['MEN_WOMEN_RATIO'].mean(), color='red', linestyle='--',
                label=f"Mean: {df2['MEN_WOMEN_RATIO'].mean():.3f}")
    ax1.set_title('Men:Women Ratio', fontweight='bold')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    ax1.tick_params(axis='x', rotation=20)

    ax2 = axes[0, 1]
    ax2.plot(x, df2['ADULT_YOUNG_RATIO'], 'o-', color='#3498db', linewidth=2, markersize=8)
    ax2.axhline(df2['ADULT_YOUNG_RATIO'].mean(), color='red', linestyle='--',
                label=f"Mean: {df2['ADULT_YOUNG_RATIO'].mean():.3f}")
    ax2.set_title('Adult:Young Ratio', fontweight='bold')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    ax2.tick_params(axis='x', rotation=20)

    ax3 = axes[1, 0]
    ax3.plot(x, df2['TITHE_OFFERINGS_RATIO'], 'o-', color='#27ae60', linewidth=2, markersize=8)
    ax3.axhline(df2['TITHE_OFFERINGS_RATIO'].mean(), color='red', linestyle='--',
                label=f"Mean: {df2['TITHE_OFFERINGS_RATIO'].mean():.3f}")
    ax3.set_title('Tithe:Offerings Ratio', fontweight='bold')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    ax3.tick_params(axis='x', rotation=20)

    ax4 = axes[1, 1]
    x_pos = np.arange(len(df2))
    width = 0.25
    ax4.bar(x_pos - width, df2['MEN_WOMEN_RATIO'], width, label='Men:Women', color='#9b59b6')
    ax4.bar(x_pos,         df2['ADULT_YOUNG_RATIO'], width, label='Adult:Young', color='#3498db')
    ax4.bar(x_pos + width, df2['TITHE_OFFERINGS_RATIO'], width, label='Tithe:Offerings', color='#27ae60')
    ax4.set_xticks(x_pos)
    ax4.set_xticklabels(x, rotation=20, fontsize=8)
    ax4.set_title('All Ratios Comparison', fontweight='bold')
    ax4.legend(fontsize=8)
    ax4.grid(axis='y', alpha=0.3)

    plt.suptitle('Dataset 2 — Ratio Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/ratio_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dataset2/ratio_analysis.png")

def ds2_plot_target_bar_charts():
    """Bar charts: each Dataset 2 parameter per Saturday vs target"""

    dates = df2['DATE'].tolist()
    x = np.arange(len(dates))
    # One colour per Saturday so every chart is visually consistent
    colors_sat = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']

    # ── Figure 1: Individual gender charts (2×2) ──────────────────────
    fig1, axes1 = plt.subplots(2, 2, figsize=(14, 10))
    gender_info = [
        ('MEN',      'Men',      targets2['MEN']),
        ('WOMEN',    'Women',    targets2['WOMEN']),
        ('YOUTH',    'Youth',    targets2['YOUTH']),
        ('CHILDREN', 'Children', targets2['CHILDREN']),
    ]
    for idx, (col, label, target) in enumerate(gender_info):
        ax = axes1[idx // 2, idx % 2]
        bars = ax.bar(x, df2[col], color=colors_sat, alpha=0.85,
                      edgecolor='white', linewidth=1.2)
        ax.axhline(target, color='red', linestyle='--', linewidth=2,
                   label=f'Target: {target:,}')
        for bar, val in zip(bars, df2[col]):
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 5,
                    f'{val:,}', ha='center', va='bottom', fontsize=9, fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(dates, rotation=15, ha='right', fontsize=9)
        ax.set_title(f'{label} Attendance per Saturday vs Target', fontweight='bold')
        ax.set_ylabel('Attendance')
        ax.legend(fontsize=9)
        ax.set_ylim(0, max(df2[col].max(), target) * 1.25)
        ax.grid(axis='y', alpha=0.3)
    fig1.suptitle('Gender Attendance per Saturday vs Targets',
                  fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/gender_per_saturday_vs_target.png',
                dpi=150, bbox_inches='tight')
    plt.show()
    print("\u2713 Saved: dataset2/gender_per_saturday_vs_target.png")

    # ── Figure 2: All genders grouped per Saturday ─────────────────────
    fig2, ax2 = plt.subplots(figsize=(14, 7))
    width = 0.18
    ax2.bar(x - 1.5 * width, df2['MEN'],      width, label='Men',
            color='#3498db', alpha=0.85, edgecolor='white')
    ax2.bar(x - 0.5 * width, df2['WOMEN'],    width, label='Women',
            color='#e74c3c', alpha=0.85, edgecolor='white')
    ax2.bar(x + 0.5 * width, df2['YOUTH'],    width, label='Youth',
            color='#2ecc71', alpha=0.85, edgecolor='white')
    ax2.bar(x + 1.5 * width, df2['CHILDREN'], width, label='Children',
            color='#f39c12', alpha=0.85, edgecolor='white')
    # Dotted target lines per gender
    for col, color, tval in [('MEN',      '#3498db', targets2['MEN']),
                              ('WOMEN',    '#e74c3c', targets2['WOMEN']),
                              ('YOUTH',    '#2ecc71', targets2['YOUTH']),
                              ('CHILDREN', '#f39c12', targets2['CHILDREN'])]:
        ax2.axhline(tval, color=color, linestyle=':', linewidth=1.8, alpha=0.75)
    ax2.set_xticks(x)
    ax2.set_xticklabels(dates, fontsize=10)
    ax2.set_title('All Genders — Four Saturdays  (dotted lines = targets)',
                  fontweight='bold', fontsize=13)
    ax2.set_ylabel('Attendance')
    ax2.legend(fontsize=10)
    ax2.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/all_genders_four_saturdays.png',
                dpi=150, bbox_inches='tight')
    plt.show()
    print("\u2713 Saved: dataset2/all_genders_four_saturdays.png")

    # ── Figure 3: Tithe per Saturday vs Target ─────────────────────────
    fig3, ax3 = plt.subplots(figsize=(10, 6))
    bars3 = ax3.bar(x, df2['TITHE'] / 1000, color=colors_sat,
                    alpha=0.85, edgecolor='white', linewidth=1.2)
    ax3.axhline(targets2['TITHE'] / 1000, color='red', linestyle='--', linewidth=2.5,
                label=f"Weekly Target: {targets2['TITHE']/1000:,.0f}K")
    for bar, val in zip(bars3, df2['TITHE']):
        ax3.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
                 f'{val/1000:,.1f}K', ha='center', va='bottom',
                 fontsize=9, fontweight='bold')
    ax3.set_xticks(x)
    ax3.set_xticklabels(dates, fontsize=10)
    ax3.set_title('Tithe per Saturday vs Target', fontweight='bold', fontsize=13)
    ax3.set_ylabel('Tithe (Thousands)')
    ax3.set_ylim(0, max(df2['TITHE'].max(), targets2['TITHE']) / 1000 * 1.30)
    ax3.legend(fontsize=10)
    ax3.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/tithe_per_saturday_vs_target.png',
                dpi=150, bbox_inches='tight')
    plt.show()
    print("\u2713 Saved: dataset2/tithe_per_saturday_vs_target.png")

    # ── Figure 4: Offerings per Saturday vs Target ─────────────────────
    fig4, ax4 = plt.subplots(figsize=(10, 6))
    bars4 = ax4.bar(x, df2['OFFERINGS'] / 1000, color=colors_sat,
                    alpha=0.85, edgecolor='white', linewidth=1.2)
    ax4.axhline(targets2['OFFERINGS'] / 1000, color='red', linestyle='--', linewidth=2.5,
                label=f"Weekly Target: {targets2['OFFERINGS']/1000:,.0f}K")
    for bar, val in zip(bars4, df2['OFFERINGS']):
        ax4.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
                 f'{val/1000:,.1f}K', ha='center', va='bottom',
                 fontsize=9, fontweight='bold')
    ax4.set_xticks(x)
    ax4.set_xticklabels(dates, fontsize=10)
    ax4.set_title('Offerings per Saturday vs Target', fontweight='bold', fontsize=13)
    ax4.set_ylabel('Offerings (Thousands)')
    ax4.set_ylim(0, max(df2['OFFERINGS'].max(), targets2['OFFERINGS']) / 1000 * 1.30)
    ax4.legend(fontsize=10)
    ax4.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/offerings_per_saturday_vs_target.png',
                dpi=150, bbox_inches='tight')
    plt.show()
    print("\u2713 Saved: dataset2/offerings_per_saturday_vs_target.png")

    # ── Figure 5: Total Attendance, Home Church & Total Income ──────────
    fig5, axes5 = plt.subplots(1, 3, figsize=(18, 6))
    extra_info = [
        (axes5[0], 'TOTAL_ATTENDANCE', 'Total Attendance',
         targets2['TOTAL_ATTENDANCE'], 1, ''),
        (axes5[1], 'HOME_CHURCH',      'Home Church',
         targets2['HOME_CHURCH'],      1, ''),
        (axes5[2], 'TOTAL_INCOME',     'Total Income',
         targets2['TITHE'] + targets2['OFFERINGS'], 1000, 'K'),
    ]
    for ax, col, label, target, divisor, unit in extra_info:
        vals = df2[col] / divisor
        tgt  = target / divisor
        bars_e = ax.bar(x, vals, color=colors_sat, alpha=0.85,
                        edgecolor='white', linewidth=1.2)
        ax.axhline(tgt, color='red', linestyle='--', linewidth=2.5,
                   label=f'Target: {tgt:,.0f}{unit}')
        for bar, val in zip(bars_e, vals):
            ax.text(bar.get_x() + bar.get_width() / 2,
                    bar.get_height() + tgt * 0.02,
                    f'{val:,.0f}{unit}', ha='center', va='bottom',
                    fontsize=9, fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(dates, rotation=15, ha='right', fontsize=9)
        ax.set_title(f'{label} per Saturday vs Target', fontweight='bold')
        ax.set_ylabel(f'{label} ({unit})' if unit else label)
        ax.set_ylim(0, max(vals.max(), tgt) * 1.30)
        ax.legend(fontsize=9)
        ax.grid(axis='y', alpha=0.3)
    fig5.suptitle('Attendance & Income Metrics per Saturday vs Targets',
                  fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/dataset2/other_metrics_per_saturday_vs_target.png',
                dpi=150, bbox_inches='tight')
    plt.show()
    print("\u2713 Saved: dataset2/other_metrics_per_saturday_vs_target.png")


def ds2_save_tables():
    """Save Dataset 2 CSV tables"""
    df2.to_csv('church_analysis/dataset2/complete_data.csv', index=False)
    print("Saved: dataset2/complete_data.csv")

    corr_vars2 = ['MEN','WOMEN','YOUTH','CHILDREN','HOME_CHURCH',
                  'TOTAL_ATTENDANCE','TITHE','OFFERINGS','TOTAL_INCOME']
    df2[corr_vars2].corr().to_csv('church_analysis/dataset2/correlation_matrix.csv')
    print("Saved: dataset2/correlation_matrix.csv")

    # Target gap table
    gap_rows = []
    for metric, pct_col in {'MEN':'MEN_TARGET_PCT','WOMEN':'WOMEN_TARGET_PCT',
                              'YOUTH':'YOUTH_TARGET_PCT','CHILDREN':'CHILDREN_TARGET_PCT',
                              'TOTAL_ATTENDANCE':'TOTAL_ATT_TARGET_PCT',
                              'HOME_CHURCH':'HOME_CHURCH_TARGET_PCT',
                              'TITHE':'TITHE_TARGET_PCT','OFFERINGS':'OFFERINGS_TARGET_PCT'}.items():
        gap_rows.append({
            'Metric': metric,
            'Target': targets2[metric],
            'Avg_Actual': df2[metric].mean(),
            'Avg_Achievement_Pct': df2[pct_col].mean(),
            'Cumulative': df2[metric].sum(),
            'Gap_from_Target_Avg': df2[metric].mean() - targets2[metric]
        })
    pd.DataFrame(gap_rows).to_csv('church_analysis/dataset2/target_gap_analysis.csv', index=False)
    print("Saved: dataset2/target_gap_analysis.csv")

def generate_ds2_all():
    """Generate all Dataset 2 analysis"""
    print("\n" + "="*80)
    print("DATASET 2 — JAN/FEB 2026 FULL ANALYSIS")
    print("="*80)
    compute_ds2_statistics()
    ds2_save_tables()
    ds2_plot_target_bar_charts()          # ← gender / tithe / offerings / other bar charts vs targets
    ds2_plot_correlation_heatmap()
    ds2_plot_attendance_trends()
    ds2_plot_financial_analysis()
    ds2_plot_target_gauge()
    ds2_plot_correlation_scatter_grid()
    ds2_plot_ratios()
    print("\nDataset 2 complete! Files saved to: church_analysis/dataset2/")

# ===================================================================
# COMBINED / CROSS-DATASET ANALYSIS
# ===================================================================

def compute_combined_statistics():
    """Compute and print cross-dataset comparison statistics"""
    print("\n" + "="*80)
    print("COMBINED CROSS-DATASET COMPARATIVE ANALYSIS")
    print("="*80)

    # Align comparable metrics
    ds1_metrics = {
        'Avg Men':            df['MEN'].mean(),
        'Avg Women':          df['WOMEN'].mean(),
        'Avg Youth':          df['YOUTH'].mean(),
        'Avg Children':       df['CHILDREN'].mean(),
        'Avg Total Att':      df['TOTAL_ATTENDANCE'].mean(),
        'Avg Home Church':    df['SUNDAY_HOME_CHURCH'].mean(),
        'Avg Tithe':          df['TITHE'].mean(),
        'Avg Offerings':      df['OFFERINGS'].mean(),
        'Avg Total Income':   df['TOTAL_INCOME'].mean(),
        'Avg Income/Attendee':df['INCOME_PER_ATTENDEE'].mean(),
        'Avg Tithe/Attendee': df['TITHE_PER_ATTENDEE'].mean(),
        'Men:Women Ratio':    (df['MEN'] / df['WOMEN']).mean(),
        'Adult:Young Ratio':  df['ADULT_YOUNG_RATIO'].mean(),
        'Tithe:Offerings':    df['TITHE_OFFERINGS_RATIO'].mean(),
    }
    ds2_metrics = {
        'Avg Men':            df2['MEN'].mean(),
        'Avg Women':          df2['WOMEN'].mean(),
        'Avg Youth':          df2['YOUTH'].mean(),
        'Avg Children':       df2['CHILDREN'].mean(),
        'Avg Total Att':      df2['TOTAL_ATTENDANCE'].mean(),
        'Avg Home Church':    df2['HOME_CHURCH'].mean(),
        'Avg Tithe':          df2['TITHE'].mean(),
        'Avg Offerings':      df2['OFFERINGS'].mean(),
        'Avg Total Income':   df2['TOTAL_INCOME'].mean(),
        'Avg Income/Attendee':df2['INCOME_PER_ATTENDEE'].mean(),
        'Avg Tithe/Attendee': df2['TITHE_PER_ATTENDEE'].mean(),
        'Men:Women Ratio':    df2['MEN_WOMEN_RATIO'].mean(),
        'Adult:Young Ratio':  df2['ADULT_YOUNG_RATIO'].mean(),
        'Tithe:Offerings':    df2['TITHE_OFFERINGS_RATIO'].mean(),
    }

    print(f"\n{'Metric':<28} {'Dataset 1':>15} {'Dataset 2':>15} {'Change %':>12}")
    print("-" * 72)
    for key in ds1_metrics:
        v1, v2 = ds1_metrics[key], ds2_metrics[key]
        chg = ((v2 - v1) / abs(v1)) * 100 if v1 != 0 else 0
        arrow = "▲" if chg > 0 else "▼"
        print(f"  {key:<26} {v1:>15,.2f} {v2:>15,.2f} {arrow}{abs(chg):>10.2f}%")

    # Save comparison table
    cmp_df = pd.DataFrame({'Metric': list(ds1_metrics.keys()),
                           'Dataset1_Avg': list(ds1_metrics.values()),
                           'Dataset2_Avg': list(ds2_metrics.values())})
    cmp_df['Change_Pct'] = ((cmp_df['Dataset2_Avg'] - cmp_df['Dataset1_Avg']) /
                             cmp_df['Dataset1_Avg'].abs()) * 100
    cmp_df.to_csv('church_analysis/combined/cross_dataset_comparison.csv', index=False)
    print("\nSaved: combined/cross_dataset_comparison.csv")
    return cmp_df

def combined_plot_avg_comparison():
    """Side-by-side average comparison bar charts"""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))

    x1 = ['Men', 'Women', 'Youth', 'Children']
    ds1_att = [df['MEN'].mean(), df['WOMEN'].mean(), df['YOUTH'].mean(), df['CHILDREN'].mean()]
    ds2_att = [df2['MEN'].mean(), df2['WOMEN'].mean(), df2['YOUTH'].mean(), df2['CHILDREN'].mean()]

    w = 0.35
    xi = np.arange(len(x1))
    ax1 = axes[0, 0]
    ax1.bar(xi - w/2, ds1_att, w, label='Dataset 1', color='#3498db', alpha=0.8)
    ax1.bar(xi + w/2, ds2_att, w, label='Dataset 2', color='#e74c3c', alpha=0.8)
    ax1.set_xticks(xi)
    ax1.set_xticklabels(x1)
    ax1.set_title('Avg Demographic Attendance: DS1 vs DS2', fontweight='bold')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)

    ax2 = axes[0, 1]
    x2 = ['Total Att', 'Home Church']
    ds1_tot = [df['TOTAL_ATTENDANCE'].mean(), df['SUNDAY_HOME_CHURCH'].mean()]
    ds2_tot = [df2['TOTAL_ATTENDANCE'].mean(), df2['HOME_CHURCH'].mean()]
    xi2 = np.arange(len(x2))
    ax2.bar(xi2 - w/2, ds1_tot, w, label='Dataset 1', color='#9b59b6', alpha=0.8)
    ax2.bar(xi2 + w/2, ds2_tot, w, label='Dataset 2', color='#1abc9c', alpha=0.8)
    ax2.set_xticks(xi2)
    ax2.set_xticklabels(x2)
    ax2.set_title('Avg Totals: DS1 vs DS2', fontweight='bold')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)

    ax3 = axes[1, 0]
    x3 = ['Tithe', 'Offerings', 'Total Income']
    ds1_fin = [df['TITHE'].mean()/1000, df['OFFERINGS'].mean()/1000, df['TOTAL_INCOME'].mean()/1000]
    ds2_fin = [df2['TITHE'].mean()/1000, df2['OFFERINGS'].mean()/1000, df2['TOTAL_INCOME'].mean()/1000]
    xi3 = np.arange(len(x3))
    ax3.bar(xi3 - w/2, ds1_fin, w, label='Dataset 1', color='#27ae60', alpha=0.8)
    ax3.bar(xi3 + w/2, ds2_fin, w, label='Dataset 2', color='#f39c12', alpha=0.8)
    ax3.set_xticks(xi3)
    ax3.set_xticklabels(x3)
    ax3.set_title('Avg Financial Metrics (K): DS1 vs DS2', fontweight='bold')
    ax3.set_ylabel('Amount (Thousands)')
    ax3.legend()
    ax3.grid(axis='y', alpha=0.3)

    ax4 = axes[1, 1]
    x4 = ['Income/Att', 'Tithe/Att', 'Men:Women', 'Tithe:Off']
    ds1_rat = [df['INCOME_PER_ATTENDEE'].mean(), df['TITHE_PER_ATTENDEE'].mean(),
               (df['MEN']/df['WOMEN']).mean(), df['TITHE_OFFERINGS_RATIO'].mean()]
    ds2_rat = [df2['INCOME_PER_ATTENDEE'].mean(), df2['TITHE_PER_ATTENDEE'].mean(),
               df2['MEN_WOMEN_RATIO'].mean(), df2['TITHE_OFFERINGS_RATIO'].mean()]
    xi4 = np.arange(len(x4))
    ax4.bar(xi4 - w/2, ds1_rat, w, label='Dataset 1', color='#e67e22', alpha=0.8)
    ax4.bar(xi4 + w/2, ds2_rat, w, label='Dataset 2', color='#8e44ad', alpha=0.8)
    ax4.set_xticks(xi4)
    ax4.set_xticklabels(x4, fontsize=9)
    ax4.set_title('Key Ratios & Per-Capita: DS1 vs DS2', fontweight='bold')
    ax4.legend()
    ax4.grid(axis='y', alpha=0.3)

    plt.suptitle('Cross-Dataset Average Comparison: Dataset 1 vs Dataset 2',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/avg_comparison.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/avg_comparison.png")

def combined_plot_change_waterfall():
    """Change % from DS1 to DS2 waterfall chart"""
    cmp_df = compute_combined_statistics()

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    metrics_att = ['Avg Men', 'Avg Women', 'Avg Youth', 'Avg Children',
                   'Avg Total Att', 'Avg Home Church']
    metrics_fin = ['Avg Tithe', 'Avg Offerings', 'Avg Total Income',
                   'Avg Income/Attendee', 'Tithe:Offerings']

    for ax, metrics, title in zip(axes,
                                   [metrics_att, metrics_fin],
                                   ['Attendance Metrics Change DS1→DS2 (%)',
                                    'Financial Metrics Change DS1→DS2 (%)']):
        sub = cmp_df[cmp_df['Metric'].isin(metrics)].set_index('Metric').reindex(metrics)
        vals = sub['Change_Pct'].values
        colors = ['#27ae60' if v >= 0 else '#e74c3c' for v in vals]
        bars = ax.barh(metrics, vals, color=colors, alpha=0.8)
        ax.axvline(0, color='black', linewidth=1)
        for bar, val in zip(bars, vals):
            xpos = val + 0.5 if val >= 0 else val - 0.5
            ha = 'left' if val >= 0 else 'right'
            ax.text(xpos, bar.get_y() + bar.get_height()/2, f'{val:+.1f}%',
                    va='center', ha=ha, fontsize=9, fontweight='bold')
        ax.set_xlabel('Percentage Change (%)')
        ax.set_title(title, fontweight='bold')
        ax.grid(axis='x', alpha=0.3)

    plt.suptitle('Dataset 1 to Dataset 2 — Percentage Change Analysis',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/change_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/change_analysis.png")

def combined_plot_correlation_overlay():
    """Overlay correlation heatmaps side by side"""
    fig, axes = plt.subplots(1, 2, figsize=(18, 8))

    shared_vars = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN', 'TOTAL_ATTENDANCE', 'TITHE', 'OFFERINGS']
    corr1 = df[shared_vars].corr()
    corr2 = df2[shared_vars].corr()

    sns.heatmap(corr1, annot=True, cmap='RdYlBu_r', center=0, fmt='.2f',
                linewidths=0.5, ax=axes[0], vmin=-1, vmax=1, annot_kws={'size': 9})
    axes[0].set_title('Dataset 1 Correlation Matrix\n(10-week historical)', fontsize=12, fontweight='bold')

    sns.heatmap(corr2, annot=True, cmap='RdYlBu_r', center=0, fmt='.2f',
                linewidths=0.5, ax=axes[1], vmin=-1, vmax=1, annot_kws={'size': 9})
    axes[1].set_title('Dataset 2 Correlation Matrix\n(Jan-Feb 2026)', fontsize=12, fontweight='bold')

    # Difference annotation below
    diff_corr = corr2 - corr1
    fig.text(0.5, -0.01, 'Note: Positive r difference = stronger correlation in DS2',
             ha='center', fontsize=10, style='italic')

    diff_corr.to_csv('church_analysis/combined/correlation_difference.csv')
    print("Saved: combined/correlation_difference.csv")

    plt.suptitle('Cross-Dataset Correlation Comparison', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/correlation_overlay.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/correlation_overlay.png")

def combined_plot_attendance_vs_income_both():
    """Attendance vs Income scatter both datasets on one chart"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax1 = axes[0]
    ax1.scatter(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME']/1000, c='#3498db', s=100,
                alpha=0.7, label='Dataset 1', edgecolors='white', linewidth=1.5, zorder=5)
    ax1.scatter(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME']/1000, c='#e74c3c', s=100,
                alpha=0.7, marker='s', label='Dataset 2', edgecolors='white', linewidth=1.5, zorder=5)

    for dataset, color, dname in [(df, '#3498db', 'DS1'), (df2, '#e74c3c', 'DS2')]:
        d_income = dataset['TOTAL_INCOME'] if 'TOTAL_INCOME' in dataset.columns else dataset['TITHE'] + dataset['OFFERINGS']
        z = np.polyfit(dataset['TOTAL_ATTENDANCE'], d_income/1000, 1)
        p = np.poly1d(z)
        xl = np.linspace(dataset['TOTAL_ATTENDANCE'].min(), dataset['TOTAL_ATTENDANCE'].max(), 100)
        ax1.plot(xl, p(xl), '--', color=color, linewidth=1.5, alpha=0.8, label=f'{dname} trend')

    ax1.set_xlabel('Total Attendance')
    ax1.set_ylabel('Total Income (K)')
    ax1.set_title('Total Attendance vs Income\n(Both Datasets)', fontweight='bold')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    ax2 = axes[1]
    ax2.scatter(df['TITHE']/1000, df['OFFERINGS']/1000, c='#3498db', s=100,
                alpha=0.7, label='Dataset 1', edgecolors='white', linewidth=1.5, zorder=5)
    ax2.scatter(df2['TITHE']/1000, df2['OFFERINGS']/1000, c='#e74c3c', s=100,
                alpha=0.7, marker='s', label='Dataset 2', edgecolors='white', linewidth=1.5, zorder=5)

    for dataset, color in [(df, '#3498db'), (df2, '#e74c3c')]:
        z = np.polyfit(dataset['TITHE']/1000, dataset['OFFERINGS']/1000, 1)
        p = np.poly1d(z)
        xl = np.linspace((dataset['TITHE']/1000).min(), (dataset['TITHE']/1000).max(), 100)
        ax2.plot(xl, p(xl), '--', color=color, linewidth=1.5, alpha=0.8)

    ax2.set_xlabel('Tithe (K)')
    ax2.set_ylabel('Offerings (K)')
    ax2.set_title('Tithe vs Offerings\n(Both Datasets)', fontweight='bold')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Cross-Dataset Scatter Overlay', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/scatter_overlay.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/scatter_overlay.png")

def combined_plot_per_capita_comparison():
    """Per capita comparison between datasets"""
    fig, axes = plt.subplots(1, 3, figsize=(16, 6))

    metrics = ['Income/Att', 'Tithe/Att', 'Offerings/Att']
    ds1_vals = [df['INCOME_PER_ATTENDEE'].mean(), df['TITHE_PER_ATTENDEE'].mean(), df['OFFERINGS_PER_ATTENDEE'].mean()]
    ds2_vals = [df2['INCOME_PER_ATTENDEE'].mean(), df2['TITHE_PER_ATTENDEE'].mean(), df2['OFFERINGS_PER_ATTENDEE'].mean()]

    for idx, (ax, metric, v1, v2) in enumerate(zip(axes, metrics, ds1_vals, ds2_vals)):
        bars = ax.bar(['Dataset 1', 'Dataset 2'], [v1, v2],
                      color=['#3498db', '#e74c3c'], alpha=0.8, width=0.5)
        for bar, val in zip(bars, [v1, v2]):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1, f'{val:.0f}',
                    ha='center', fontsize=11, fontweight='bold')
        chg = ((v2 - v1) / abs(v1)) * 100
        arrow = '▲' if chg > 0 else '▼'
        ax.set_title(f'{metric}\n{arrow} {abs(chg):.1f}% change', fontweight='bold')
        ax.set_ylabel('Amount per Attendee')
        ax.grid(axis='y', alpha=0.3)

    plt.suptitle('Per Capita Metrics: Dataset 1 vs Dataset 2', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/per_capita_comparison.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/per_capita_comparison.png")

def combined_plot_ds2_vs_targets_and_ds1_benchmark():
    """DS2 actuals vs targets AND DS1 averages as a 3-way comparison"""
    categories = ['Men', 'Women', 'Youth', 'Children', 'Total Att', 'Home Church']
    ds1_avgs = [df['MEN'].mean(), df['WOMEN'].mean(), df['YOUTH'].mean(),
                df['CHILDREN'].mean(), df['TOTAL_ATTENDANCE'].mean(), df['SUNDAY_HOME_CHURCH'].mean()]
    ds2_avgs = [df2['MEN'].mean(), df2['WOMEN'].mean(), df2['YOUTH'].mean(),
                df2['CHILDREN'].mean(), df2['TOTAL_ATTENDANCE'].mean(), df2['HOME_CHURCH'].mean()]
    tgt_vals = [targets2['MEN'], targets2['WOMEN'], targets2['YOUTH'],
                targets2['CHILDREN'], targets2['TOTAL_ATTENDANCE'], targets2['HOME_CHURCH']]

    x = np.arange(len(categories))
    w = 0.25
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    ax1 = axes[0]
    ax1.bar(x - w, ds1_avgs, w, label='DS1 Avg', color='#3498db', alpha=0.8)
    ax1.bar(x,     ds2_avgs, w, label='DS2 Avg', color='#e74c3c', alpha=0.8)
    ax1.bar(x + w, tgt_vals, w, label='DS2 Target', color='#27ae60', alpha=0.8)
    ax1.set_xticks(x)
    ax1.set_xticklabels(categories, rotation=15, ha='right')
    ax1.set_title('Attendance: DS1 Avg vs DS2 Avg vs Targets', fontweight='bold')
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)

    # Finance 3-way
    fin_cats = ['Tithe', 'Offerings', 'Total Income']
    ds1_fin = [df['TITHE'].mean()/1000, df['OFFERINGS'].mean()/1000, df['TOTAL_INCOME'].mean()/1000]
    ds2_fin = [df2['TITHE'].mean()/1000, df2['OFFERINGS'].mean()/1000, df2['TOTAL_INCOME'].mean()/1000]
    tgt_fin = [targets2['TITHE']/1000, targets2['OFFERINGS']/1000,
               (targets2['TITHE'] + targets2['OFFERINGS'])/1000]

    xf = np.arange(len(fin_cats))
    ax2 = axes[1]
    ax2.bar(xf - w, ds1_fin, w, label='DS1 Avg', color='#3498db', alpha=0.8)
    ax2.bar(xf,     ds2_fin, w, label='DS2 Avg', color='#e74c3c', alpha=0.8)
    ax2.bar(xf + w, tgt_fin, w, label='DS2 Target', color='#27ae60', alpha=0.8)
    ax2.set_xticks(xf)
    ax2.set_xticklabels(fin_cats)
    ax2.set_title('Finance (K): DS1 Avg vs DS2 Avg vs Targets', fontweight='bold')
    ax2.set_ylabel('Amount (Thousands)')
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)

    plt.suptitle('Three-Way Comparison: DS1 Historical Avg, DS2 Actual, DS2 Targets',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church_analysis/combined/threeway_comparison.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/threeway_comparison.png")

def combined_plot_master_dashboard():
    """Master combined dashboard"""
    fig = plt.figure(figsize=(22, 18))
    gs = fig.add_gridspec(4, 4, hspace=0.4, wspace=0.35)

    # -- Row 0: trends --
    ax0 = fig.add_subplot(gs[0, 0:2])
    ax0.plot(range(1, 11), df['TOTAL_ATTENDANCE'], 'o-', color='#3498db', linewidth=2, label='DS1 Total Att')
    ax0.plot(range(1, 5), df2['TOTAL_ATTENDANCE'], 's--', color='#e74c3c', linewidth=2, label='DS2 Total Att')
    ax0.axhline(targets2['TOTAL_ATTENDANCE'], color='green', linestyle=':', linewidth=2, label=f"Target {targets2['TOTAL_ATTENDANCE']:,}")
    ax0.set_title('Total Attendance – Both Datasets', fontweight='bold')
    ax0.set_xlabel('Week')
    ax0.legend(fontsize=8)
    ax0.grid(True, alpha=0.3)

    ax1 = fig.add_subplot(gs[0, 2:4])
    ax1.plot(range(1, 11), df['TOTAL_INCOME']/1000, 'o-', color='#3498db', linewidth=2, label='DS1 Total Income')
    ax1.plot(range(1, 5), df2['TOTAL_INCOME']/1000, 's--', color='#e74c3c', linewidth=2, label='DS2 Total Income')
    ax1.axhline((targets2['TITHE'] + targets2['OFFERINGS'])/1000, color='green', linestyle=':', linewidth=2, label='Target Income')
    ax1.set_title('Total Income (K) – Both Datasets', fontweight='bold')
    ax1.set_xlabel('Week')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # -- Row 1: scatter overlays --
    ax2 = fig.add_subplot(gs[1, 0:2])
    ax2.scatter(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME']/1000, c='#3498db', s=70, alpha=0.8, label='DS1')
    ax2.scatter(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME']/1000, c='#e74c3c', s=100, marker='s', alpha=0.8, label='DS2')
    for dset, color in [(df, '#3498db'), (df2, '#e74c3c')]:
        z = np.polyfit(dset['TOTAL_ATTENDANCE'], dset['TOTAL_INCOME']/1000, 1)
        xl = np.linspace(dset['TOTAL_ATTENDANCE'].min(), dset['TOTAL_ATTENDANCE'].max(), 50)
        ax2.plot(xl, np.poly1d(z)(xl), '--', color=color, linewidth=1.5)
    ax2.set_xlabel('Total Attendance')
    ax2.set_ylabel('Total Income (K)')
    ax2.set_title('Att vs Income (Both Datasets)', fontweight='bold')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    ax3 = fig.add_subplot(gs[1, 2:4])
    cats = ['Men', 'Women', 'Youth', 'Children']
    ds1_a = [df['MEN'].mean(), df['WOMEN'].mean(), df['YOUTH'].mean(), df['CHILDREN'].mean()]
    ds2_a = [df2['MEN'].mean(), df2['WOMEN'].mean(), df2['YOUTH'].mean(), df2['CHILDREN'].mean()]
    tgt_a = [targets2['MEN'], targets2['WOMEN'], targets2['YOUTH'], targets2['CHILDREN']]
    xi = np.arange(len(cats)); w = 0.25
    ax3.bar(xi - w, ds1_a, w, color='#3498db', alpha=0.8, label='DS1 Avg')
    ax3.bar(xi,     ds2_a, w, color='#e74c3c', alpha=0.8, label='DS2 Avg')
    ax3.bar(xi + w, tgt_a, w, color='#27ae60', alpha=0.8, label='Target')
    ax3.set_xticks(xi)
    ax3.set_xticklabels(cats)
    ax3.set_title('Demographics: DS1 vs DS2 vs Target', fontweight='bold')
    ax3.legend(fontsize=8)
    ax3.grid(axis='y', alpha=0.3)

    # -- Row 2: financial comparison --
    ax4 = fig.add_subplot(gs[2, 0:2])
    fin_cats2 = ['Tithe', 'Offerings']
    ds1_f = [df['TITHE'].mean()/1000, df['OFFERINGS'].mean()/1000]
    ds2_f = [df2['TITHE'].mean()/1000, df2['OFFERINGS'].mean()/1000]
    tgt_f = [targets2['TITHE']/1000, targets2['OFFERINGS']/1000]
    xf = np.arange(2)
    ax4.bar(xf - w, ds1_f, w, color='#3498db', alpha=0.8, label='DS1 Avg')
    ax4.bar(xf,     ds2_f, w, color='#e74c3c', alpha=0.8, label='DS2 Avg')
    ax4.bar(xf + w, tgt_f, w, color='#27ae60', alpha=0.8, label='Target')
    ax4.set_xticks(xf)
    ax4.set_xticklabels(fin_cats2)
    ax4.set_title('Finance (K): DS1 vs DS2 vs Target', fontweight='bold')
    ax4.legend(fontsize=8)
    ax4.grid(axis='y', alpha=0.3)

    # Per capita comparison
    ax5 = fig.add_subplot(gs[2, 2:4])
    pc_cats = ['Income/Att', 'Tithe/Att', 'Off/Att']
    ds1_pc = [df['INCOME_PER_ATTENDEE'].mean(), df['TITHE_PER_ATTENDEE'].mean(), df['OFFERINGS_PER_ATTENDEE'].mean()]
    ds2_pc = [df2['INCOME_PER_ATTENDEE'].mean(), df2['TITHE_PER_ATTENDEE'].mean(), df2['OFFERINGS_PER_ATTENDEE'].mean()]
    xp = np.arange(len(pc_cats))
    ax5.bar(xp - 0.2, ds1_pc, 0.4, color='#3498db', alpha=0.8, label='DS1')
    ax5.bar(xp + 0.2, ds2_pc, 0.4, color='#e74c3c', alpha=0.8, label='DS2')
    ax5.set_xticks(xp)
    ax5.set_xticklabels(pc_cats)
    ax5.set_title('Per Capita: DS1 vs DS2', fontweight='bold')
    ax5.legend(fontsize=8)
    ax5.grid(axis='y', alpha=0.3)

    # -- Row 3: Stats summary table --
    ax6 = fig.add_subplot(gs[3, :])
    ax6.axis('off')

    r1, _ = pearsonr(df['TOTAL_ATTENDANCE'], df['TOTAL_INCOME'])
    r2, _ = pearsonr(df2['TOTAL_ATTENDANCE'], df2['TOTAL_INCOME'])

    summary = (
        f"{'='*120}\n"
        f"  CROSS-DATASET SUMMARY\n"
        f"  {'Metric':<30} {'Dataset 1 (10-week)':>25} {'Dataset 2 (Jan-Feb 2026)':>28} {'DS2 Target':>20}\n"
        f"  {'-'*103}\n"
        f"  {'Avg Total Attendance':<30} {df['TOTAL_ATTENDANCE'].mean():>25,.0f} {df2['TOTAL_ATTENDANCE'].mean():>28,.0f} {targets2['TOTAL_ATTENDANCE']:>20,}\n"
        f"  {'Avg Tithe':<30} {df['TITHE'].mean():>25,.0f} {df2['TITHE'].mean():>28,.0f} {targets2['TITHE']:>20,.0f}\n"
        f"  {'Avg Offerings':<30} {df['OFFERINGS'].mean():>25,.0f} {df2['OFFERINGS'].mean():>28,.0f} {targets2['OFFERINGS']:>20,.0f}\n"
        f"  {'Avg Total Income':<30} {df['TOTAL_INCOME'].mean():>25,.0f} {df2['TOTAL_INCOME'].mean():>28,.0f} {targets2['TITHE']+targets2['OFFERINGS']:>20,.0f}\n"
        f"  {'Income per Attendee':<30} {df['INCOME_PER_ATTENDEE'].mean():>25,.2f} {df2['INCOME_PER_ATTENDEE'].mean():>28,.2f} {'N/A':>20}\n"
        f"  {'Att-Income Pearson r':<30} {r1:>25.4f} {r2:>28.4f} {'N/A':>20}\n"
        f"{'='*120}"
    )
    ax6.text(0.01, 0.5, summary, transform=ax6.transAxes, fontsize=8.5,
             verticalalignment='center', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.6))

    fig.suptitle('MASTER COMBINED DASHBOARD — Church Data Analysis',
                 fontsize=16, fontweight='bold', y=1.01)
    plt.savefig('church_analysis/combined/master_dashboard.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: combined/master_dashboard.png")

def generate_combined_all():
    """Generate all combined/cross-dataset analysis"""
    print("\n" + "="*80)
    print("COMBINED CROSS-DATASET ANALYSIS")
    print("="*80)
    compute_combined_statistics()
    combined_plot_avg_comparison()
    combined_plot_change_waterfall()
    combined_plot_correlation_overlay()
    combined_plot_attendance_vs_income_both()
    combined_plot_per_capita_comparison()
    combined_plot_ds2_vs_targets_and_ds1_benchmark()
    combined_plot_master_dashboard()
    print("\nCombined analysis complete! Files saved to: church_analysis/combined/")

# ============================================
# MAIN EXECUTION
# ============================================

if __name__ == "__main__":
    # ---- DATASET 1 ----
    print("\n" + "#"*80)
    print("# SECTION 1: DATASET 1 ANALYSIS (10-week historical)")
    print("#"*80)
    generate_all()

    # ---- DATASET 2 ----
    print("\n" + "#"*80)
    print("# SECTION 2: DATASET 2 ANALYSIS (Jan-Feb 2026 with Targets)")
    print("#"*80)
    generate_ds2_all()

    # ---- COMBINED ----
    print("\n" + "#"*80)
    print("# SECTION 3: COMBINED CROSS-DATASET ANALYSIS")
    print("#"*80)
    generate_combined_all()

    print("\n" + "="*80)
    print("ALL ANALYSES COMPLETE!")
    print("="*80)
    print("\nOutput structure:")
    print("  church_analysis/dataset1/  — 21 graphs + 7 CSV files (10-week data)")
    print("  church_analysis/dataset2/  — 6 graphs + 3 CSV files (Jan-Feb 2026 + targets)")
    print("  church_analysis/combined/  — 7 graphs + 3 CSV files (cross-dataset)")
    print("="*80)

