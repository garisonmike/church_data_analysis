import pandas as pd 
import matplotlib.pyplot as plt
import numpy as np
import os

# Create output directory if it doesn't exist
os.makedirs('church', exist_ok=True)

# Church Attendance and Financial Data
data = {
    'SATURDAY': ['NO1', 'NO2', 'NO3', 'NO4', 'NO5', 'NO6', 'NO7', 'NO8', 'NO9', 'NO10'],
    'MEN': [504, 602, 569, 452, 498, 520, 624, 587, 594, 635],
    'WOMEN': [812, 784, 895, 916, 856, 845, 988, 742, 819, 901], 
    'YOUTH': [356, 368, 394, 422, 415, 485, 510, 386, 446, 487], 
    'CHILDREN': [214, 259, 287, 309, 324, 258, 274, 301, 295, 348],
    'SUNDAY HOME CHURCH': [456, 358, 412, 425, 387, 348, 397, 458, 374, 410],
    'TITHE': [120145, 148748, 84852, 132245, 145350, 220145, 156846, 94578, 124698, 88749],
    'OFFERINGS': [89457, 101254, 74128, 121145, 91487, 110846, 105497, 81249, 99458, 81249],
    'EMERGENCYCOLLECTION': [0, 0, 48521, 0, 0, 0, 0, 68947, 0, 78948],
    'PLANNEDCOLLECTION': [0, 0, 0, 0, 455648, 0, 0, 0, 358947, 0]
}         

df = pd.DataFrame(data)

# Calculate totals for analysis
df['TOTAL_ATTENDANCE'] = df['MEN'] + df['WOMEN'] + df['YOUTH'] + df['CHILDREN']
df['TOTAL_INCOME'] = df['TITHE'] + df['OFFERINGS'] + df['EMERGENCYCOLLECTION'] + df['PLANNEDCOLLECTION']

# Set up the figure style
plt.style.use('seaborn-v0_8-whitegrid')

# ============================================
# GRAPH FUNCTIONS
# ============================================

def show_data_summary():
    """Display data summary and statistics"""
    rows, columns = df.shape
    print(f"\nRows: {rows}, Columns: {columns}")
    print(df)
    print("\n--- Statistical Summary ---")
    print(df.describe())

def graph1_attendance_by_category():
    """Weekly Attendance Trends by Category"""
    fig1, ax1 = plt.subplots(figsize=(12, 6))
    x = range(len(df['SATURDAY']))
    width = 0.2

    ax1.bar([i - 1.5*width for i in x], df['MEN'], width, label='Men', color='#3498db')
    ax1.bar([i - 0.5*width for i in x], df['WOMEN'], width, label='Women', color='#e74c3c')
    ax1.bar([i + 0.5*width for i in x], df['YOUTH'], width, label='Youth', color='#2ecc71')
    ax1.bar([i + 1.5*width for i in x], df['CHILDREN'], width, label='Children', color='#f39c12')

    ax1.set_xlabel('Saturday Service', fontsize=12)
    ax1.set_ylabel('Number of Attendees', fontsize=12)
    ax1.set_title('Weekly Church Attendance by Category', fontsize=14, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels(df['SATURDAY'])
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('church/attendance_by_category.png', dpi=150)
    plt.show()
    print("✓ Saved: attendance_by_category.png")

def graph2_total_attendance_trend():
    """Total Attendance Trend Line"""
    fig2, ax2 = plt.subplots(figsize=(10, 5))
    ax2.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], marker='o', linewidth=2, 
             markersize=8, color='#9b59b6', label='Total Attendance')
    ax2.fill_between(df['SATURDAY'], df['TOTAL_ATTENDANCE'], alpha=0.3, color='#9b59b6')

    z = np.polyfit(range(len(df)), df['TOTAL_ATTENDANCE'], 1)
    p = np.poly1d(z)
    ax2.plot(df['SATURDAY'], p(range(len(df))), '--', color='red', linewidth=2, label='Trend Line')

    ax2.set_xlabel('Saturday Service', fontsize=12)
    ax2.set_ylabel('Total Attendance', fontsize=12)
    ax2.set_title('Total Weekly Attendance Trend', fontsize=14, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('church/total_attendance_trend.png', dpi=150)
    plt.show()
    print("✓ Saved: total_attendance_trend.png")

def graph3_attendance_pie():
    """Attendance Distribution Pie Chart (Saturday Service Only)"""
    fig3, ax3 = plt.subplots(figsize=(8, 8))
    attendance_categories = ['Men', 'Women', 'Youth', 'Children']
    attendance_totals = [df['MEN'].sum(), df['WOMEN'].sum(), df['YOUTH'].sum(), 
                         df['CHILDREN'].sum()]
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    explode = (0, 0.05, 0, 0)

    ax3.pie(attendance_totals, explode=explode, labels=attendance_categories, colors=colors,
            autopct='%1.1f%%', shadow=True, startangle=90)
    ax3.set_title('Saturday Service Attendance Distribution', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church/attendance_distribution_pie.png', dpi=150)
    plt.show()
    print("✓ Saved: attendance_distribution_pie.png")

def graph4_tithe_vs_offerings():
    """Tithe vs Offerings Comparison"""
    fig4, ax4 = plt.subplots(figsize=(12, 6))
    x = range(len(df['SATURDAY']))
    width = 0.35

    bars1 = ax4.bar([i - width/2 for i in x], df['TITHE']/1000, width, label='Tithe', color='#27ae60')
    bars2 = ax4.bar([i + width/2 for i in x], df['OFFERINGS']/1000, width, label='Offerings', color='#3498db')

    ax4.set_xlabel('Saturday Service', fontsize=12)
    ax4.set_ylabel('Amount (in Thousands)', fontsize=12)
    ax4.set_title('Weekly Tithe vs Offerings Comparison', fontsize=14, fontweight='bold')
    ax4.set_xticks(x)
    ax4.set_xticklabels(df['SATURDAY'])
    ax4.legend()
    ax4.grid(axis='y', alpha=0.3)

    for bar in bars1:
        height = bar.get_height()
        ax4.annotate(f'{height:.0f}K', xy=(bar.get_x() + bar.get_width()/2, height),
                     xytext=(0, 3), textcoords="offset points", ha='center', va='bottom', fontsize=8)

    plt.tight_layout()
    plt.savefig('church/tithe_vs_offerings.png', dpi=150)
    plt.show()
    print("✓ Saved: tithe_vs_offerings.png")

def graph5_income_breakdown():
    """Total Income Breakdown (Stacked)"""
    fig5, ax5 = plt.subplots(figsize=(12, 6))
    ax5.stackplot(df['SATURDAY'], 
                  df['TITHE']/1000, 
                  df['OFFERINGS']/1000, 
                  df['EMERGENCYCOLLECTION']/1000, 
                  df['PLANNEDCOLLECTION']/1000,
                  labels=['Tithe', 'Offerings', 'Emergency Collection', 'Planned Collection'],
                  colors=['#27ae60', '#3498db', '#e74c3c', '#f39c12'], alpha=0.8)

    ax5.set_xlabel('Saturday Service', fontsize=12)
    ax5.set_ylabel('Amount (in Thousands)', fontsize=12)
    ax5.set_title('Total Weekly Income Breakdown', fontsize=14, fontweight='bold')
    ax5.legend(loc='upper left')
    ax5.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('church/income_breakdown.png', dpi=150)
    plt.show()
    print("✓ Saved: income_breakdown.png")

def graph6_income_pie():
    """Income Distribution Pie Chart"""
    fig6, ax6 = plt.subplots(figsize=(8, 8))
    income_categories = ['Tithe', 'Offerings', 'Emergency Collection', 'Planned Collection']
    income_totals = [df['TITHE'].sum(), df['OFFERINGS'].sum(), 
                     df['EMERGENCYCOLLECTION'].sum(), df['PLANNEDCOLLECTION'].sum()]
    colors = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']

    ax6.pie(income_totals, labels=income_categories, colors=colors,
            autopct='%1.1f%%', shadow=True, startangle=90)
    ax6.set_title('Total Income Distribution', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church/income_distribution_pie.png', dpi=150)
    plt.show()
    print("✓ Saved: income_distribution_pie.png")

def graph7_attendance_vs_income():
    """Attendance vs Income Correlation"""
    fig7, ax7 = plt.subplots(figsize=(10, 6))
    ax7_twin = ax7.twinx()

    ax7.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', 
             linewidth=2, markersize=8, label='Total Attendance')
    ax7_twin.plot(df['SATURDAY'], df['TOTAL_INCOME']/1000, 's-', color='#27ae60', 
                  linewidth=2, markersize=8, label='Total Income (K)')

    ax7.set_xlabel('Saturday Service', fontsize=12)
    ax7.set_ylabel('Total Attendance', fontsize=12, color='#9b59b6')
    ax7_twin.set_ylabel('Total Income (Thousands)', fontsize=12, color='#27ae60')
    ax7.set_title('Attendance vs Income Correlation', fontsize=14, fontweight='bold')

    lines1, labels1 = ax7.get_legend_handles_labels()
    lines2, labels2 = ax7_twin.get_legend_handles_labels()
    ax7.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax7.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('church/attendance_vs_income.png', dpi=150)
    plt.show()
    print("✓ Saved: attendance_vs_income.png")

def graph8_dashboard():
    """Complete Dashboard Summary"""
    fig8, axes = plt.subplots(2, 2, figsize=(14, 10))

    ax_tl = axes[0, 0]
    categories = ['Men', 'Women', 'Youth', 'Children', 'Home Church']
    averages = [df['MEN'].mean(), df['WOMEN'].mean(), df['YOUTH'].mean(), 
                df['CHILDREN'].mean(), df['SUNDAY HOME CHURCH'].mean()]
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6']
    bars = ax_tl.barh(categories, averages, color=colors)
    ax_tl.set_xlabel('Average Attendance')
    ax_tl.set_title('Average Attendance by Category', fontweight='bold')
    for bar, val in zip(bars, averages):
        ax_tl.text(val + 5, bar.get_y() + bar.get_height()/2, f'{val:.0f}', va='center')

    ax_tr = axes[0, 1]
    income_cats = ['Tithe', 'Offerings', 'Emergency', 'Planned']
    income_avgs = [df['TITHE'].mean()/1000, df['OFFERINGS'].mean()/1000, 
                   df['EMERGENCYCOLLECTION'].mean()/1000, df['PLANNEDCOLLECTION'].mean()/1000]
    colors_inc = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']
    bars = ax_tr.barh(income_cats, income_avgs, color=colors_inc)
    ax_tr.set_xlabel('Average Amount (Thousands)')
    ax_tr.set_title('Average Income by Source', fontweight='bold')
    for bar, val in zip(bars, income_avgs):
        ax_tr.text(val + 2, bar.get_y() + bar.get_height()/2, f'{val:.1f}K', va='center')

    ax_bl = axes[1, 0]
    growth_data = df['TOTAL_ATTENDANCE'].pct_change().fillna(0) * 100
    colors_growth = ['#27ae60' if x >= 0 else '#e74c3c' for x in growth_data]
    ax_bl.bar(df['SATURDAY'], growth_data, color=colors_growth)
    ax_bl.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax_bl.set_xlabel('Saturday Service')
    ax_bl.set_ylabel('Growth Rate (%)')
    ax_bl.set_title('Week-over-Week Attendance Growth', fontweight='bold')

    ax_br = axes[1, 1]
    ax_br.axis('off')
    stats_text = f"""
CHURCH STATISTICS SUMMARY
{'='*40}

ATTENDANCE METRICS:
• Total Attendance (All Weeks): {df['TOTAL_ATTENDANCE'].sum():,}
• Average Weekly Attendance: {df['TOTAL_ATTENDANCE'].mean():,.0f}
• Highest Attendance: {df['TOTAL_ATTENDANCE'].max():,} (Week {int(df['TOTAL_ATTENDANCE'].idxmax()) + 1})
• Lowest Attendance: {df['TOTAL_ATTENDANCE'].min():,} (Week {int(df['TOTAL_ATTENDANCE'].idxmin()) + 1})

FINANCIAL METRICS:
• Total Income (All Weeks): {df['TOTAL_INCOME'].sum():,}
• Average Weekly Income: {df['TOTAL_INCOME'].mean():,.0f}
• Highest Income Week: {df['TOTAL_INCOME'].max():,}
• Total Tithe Collected: {df['TITHE'].sum():,}
• Total Offerings Collected: {df['OFFERINGS'].sum():,}

DEMOGRAPHICS:
• Women: {df['WOMEN'].sum():,} ({df['WOMEN'].sum()/df['TOTAL_ATTENDANCE'].sum()*100:.1f}%)
• Men: {df['MEN'].sum():,} ({df['MEN'].sum()/df['TOTAL_ATTENDANCE'].sum()*100:.1f}%)
• Youth: {df['YOUTH'].sum():,} ({df['YOUTH'].sum()/df['TOTAL_ATTENDANCE'].sum()*100:.1f}%)
• Children: {df['CHILDREN'].sum():,} ({df['CHILDREN'].sum()/df['TOTAL_ATTENDANCE'].sum()*100:.1f}%)
"""
    ax_br.text(0.1, 0.95, stats_text, transform=ax_br.transAxes, fontsize=10,
               verticalalignment='top', fontfamily='monospace',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.suptitle('Church Dashboard Summary', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('church/dashboard_summary.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("✓ Saved: dashboard_summary.png")

def graph9_sunday_home_church_vs_funds():
    """Sunday Home Church Attendance vs All Funds"""
    fig9, ax9 = plt.subplots(figsize=(12, 6))
    ax9_twin = ax9.twinx()
    
    x = range(len(df['SATURDAY']))
    ax9.plot(df['SATURDAY'], df['SUNDAY HOME CHURCH'], 'o-', color='#9b59b6', 
             linewidth=2, markersize=8, label='Sunday Home Church')
    
    ax9_twin.plot(df['SATURDAY'], df['TITHE']/1000, 's-', color='#27ae60', 
                  linewidth=2, markersize=6, label='Tithe (K)', alpha=0.7)
    ax9_twin.plot(df['SATURDAY'], df['OFFERINGS']/1000, '^-', color='#3498db', 
                  linewidth=2, markersize=6, label='Offerings (K)', alpha=0.7)
    ax9_twin.plot(df['SATURDAY'], df['EMERGENCYCOLLECTION']/1000, 'd-', color='#e74c3c', 
                  linewidth=2, markersize=6, label='Emergency (K)', alpha=0.7)
    ax9_twin.plot(df['SATURDAY'], df['PLANNEDCOLLECTION']/1000, 'v-', color='#f39c12', 
                  linewidth=2, markersize=6, label='Planned (K)', alpha=0.7)
    
    ax9.set_xlabel('Saturday Service', fontsize=12)
    ax9.set_ylabel('Sunday Home Church Attendance', fontsize=12, color='#9b59b6')
    ax9_twin.set_ylabel('Fund Amounts (Thousands)', fontsize=12)
    ax9.set_title('Sunday Home Church Attendance vs All Funds', fontsize=14, fontweight='bold')
    ax9.tick_params(axis='y', labelcolor='#9b59b6')
    
    lines1, labels1 = ax9.get_legend_handles_labels()
    lines2, labels2 = ax9_twin.get_legend_handles_labels()
    ax9.legend(lines1 + lines2, labels1 + labels2, loc='upper left')
    ax9.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('church/sunday_home_vs_funds.png', dpi=150)
    plt.show()
    print("✓ Saved: sunday_home_vs_funds.png")

def graph10_demographics_vs_funds():
    """Each Demographic Group vs All Funds (4 Subplots)"""
    fig10, axes = plt.subplots(2, 2, figsize=(16, 12))
    demographics = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN']
    titles = ['Men', 'Women', 'Youth', 'Children']
    colors_demo = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    
    for idx, (demo, title, color) in enumerate(zip(demographics, titles, colors_demo)):
        ax = axes[idx // 2, idx % 2]
        ax_twin = ax.twinx()
        
        ax.plot(df['SATURDAY'], df[demo], 'o-', color=color, linewidth=2, 
                markersize=8, label=title, alpha=0.9)
        
        ax_twin.plot(df['SATURDAY'], df['TITHE']/1000, 's--', color='#27ae60', 
                     linewidth=1.5, markersize=5, label='Tithe (K)', alpha=0.6)
        ax_twin.plot(df['SATURDAY'], df['OFFERINGS']/1000, '^--', color='#3498db', 
                     linewidth=1.5, markersize=5, label='Offerings (K)', alpha=0.6)
        ax_twin.plot(df['SATURDAY'], df['EMERGENCYCOLLECTION']/1000, 'd--', color='#e74c3c', 
                     linewidth=1.5, markersize=5, label='Emergency (K)', alpha=0.6)
        ax_twin.plot(df['SATURDAY'], df['PLANNEDCOLLECTION']/1000, 'v--', color='#f39c12', 
                     linewidth=1.5, markersize=5, label='Planned (K)', alpha=0.6)
        
        ax.set_xlabel('Saturday Service', fontsize=10)
        ax.set_ylabel(f'{title} Attendance', fontsize=10, color=color)
        ax_twin.set_ylabel('Fund Amounts (Thousands)', fontsize=10)
        ax.set_title(f'{title} vs All Funds', fontsize=12, fontweight='bold')
        ax.tick_params(axis='y', labelcolor=color)
        ax.grid(True, alpha=0.3)
        
        if idx == 0:
            lines1, labels1 = ax.get_legend_handles_labels()
            lines2, labels2 = ax_twin.get_legend_handles_labels()
            ax.legend(lines1 + lines2, labels1 + labels2, loc='upper left', fontsize=8)
    
    plt.suptitle('Demographic Groups vs Fund Collections', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church/demographics_vs_funds.png', dpi=150)
    plt.show()
    print("✓ Saved: demographics_vs_funds.png")

def graph11_funds_vs_total_attendance():
    """Each Fund vs Total Attendance"""
    fig11, axes = plt.subplots(2, 2, figsize=(14, 10))
    funds = ['TITHE', 'OFFERINGS', 'EMERGENCYCOLLECTION', 'PLANNEDCOLLECTION']
    titles = ['Tithe', 'Offerings', 'Emergency Collection', 'Planned Collection']
    colors_funds = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']
    
    for idx, (fund, title, color) in enumerate(zip(funds, titles, colors_funds)):
        ax = axes[idx // 2, idx % 2]
        ax_twin = ax.twinx()
        
        ax.bar(df['SATURDAY'], df[fund]/1000, color=color, alpha=0.7, label=title)
        ax_twin.plot(df['SATURDAY'], df['TOTAL_ATTENDANCE'], 'o-', color='#9b59b6', 
                     linewidth=2, markersize=8, label='Total Attendance')
        
        ax.set_xlabel('Saturday Service', fontsize=10)
        ax.set_ylabel(f'{title} (Thousands)', fontsize=10, color=color)
        ax_twin.set_ylabel('Total Attendance', fontsize=10, color='#9b59b6')
        ax.set_title(f'{title} vs Total Attendance', fontsize=12, fontweight='bold')
        ax.tick_params(axis='y', labelcolor=color)
        ax_twin.tick_params(axis='y', labelcolor='#9b59b6')
        
        lines1, labels1 = ax.get_legend_handles_labels()
        lines2, labels2 = ax_twin.get_legend_handles_labels()
        ax.legend(lines1 + lines2, labels1 + labels2, loc='upper left', fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Fund Collections vs Total Attendance', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church/funds_vs_attendance.png', dpi=150)
    plt.show()
    print("✓ Saved: funds_vs_attendance.png")

def graph12_all_groups_vs_each_fund():
    """All Demographic Groups vs Each Fund (Correlation)"""
    fig12, axes = plt.subplots(2, 2, figsize=(14, 10))
    funds = ['TITHE', 'OFFERINGS', 'EMERGENCYCOLLECTION', 'PLANNEDCOLLECTION']
    titles = ['Tithe', 'Offerings', 'Emergency Collection', 'Planned Collection']
    colors_funds = ['#27ae60', '#3498db', '#e74c3c', '#f39c12']
    demographics = ['MEN', 'WOMEN', 'YOUTH', 'CHILDREN']
    demo_labels = ['Men', 'Women', 'Youth', 'Children']
    demo_colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    
    for idx, (fund, title, color) in enumerate(zip(funds, titles, colors_funds)):
        ax = axes[idx // 2, idx % 2]
        
        for demo, label, d_color in zip(demographics, demo_labels, demo_colors):
            ax.scatter(df[demo], df[fund]/1000, label=label, alpha=0.6, s=80, color=d_color)
        
        ax.set_xlabel('Attendance Count', fontsize=10)
        ax.set_ylabel(f'{title} (Thousands)', fontsize=10)
        ax.set_title(f'All Groups vs {title}', fontsize=12, fontweight='bold')
        ax.legend(loc='best', fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Demographic Groups vs Individual Funds (Correlation)', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('church/groups_vs_funds_correlation.png', dpi=150)
    plt.show()
    print("✓ Saved: groups_vs_funds_correlation.png")

# ============================================
# MENU SYSTEM
# ============================================

def display_menu():
    """Display the main menu"""
    print("\n" + "="*70)
    print("         CHURCH DATA ANALYSIS - GRAPH GENERATOR")
    print("="*70)
    print("\nAvailable Graphs:")
    print("-"*70)
    print("  0. Show Data Summary (Table & Statistics)")
    print("-"*70)
    print("  ATTENDANCE GRAPHS:")
    print("  1. Weekly Attendance by Category (Bar Chart)")
    print("  2. Total Attendance Trend (Line Chart)")
    print("  3. Saturday Service Attendance Distribution (Pie Chart)")
    print("-"*70)
    print("  FINANCIAL GRAPHS:")
    print("  4. Tithe vs Offerings Comparison (Bar Chart)")
    print("  5. Income Breakdown (Stacked Area Chart)")
    print("  6. Income Distribution (Pie Chart)")
    print("-"*70)
    print("  COMBINED ANALYSIS:")
    print("  7. Attendance vs Income Correlation (Dual Axis)")
    print("  8. Complete Dashboard Summary (Multi-Panel)")
    print("-"*70)
    print("  NEW CORRELATION GRAPHS:")
    print("  9. Sunday Home Church vs All Funds")
    print(" 10. Demographics vs Funds (4 Subplots)")
    print(" 11. Funds vs Total Attendance (4 Subplots)")
    print(" 12. All Groups vs Each Fund (Correlation Scatter)")
    print("-"*70)
    print(" 99. Generate ALL Graphs")
    print("  Q. Quit")
    print("="*70)

def get_user_selection():
    """Get and validate user input"""
    while True:
        user_input = input("\nEnter your choice(s) (e.g., 1,3,5 or 1-12 or 99 for all): ").strip().upper()
        
        if user_input == 'Q':
            return None
        
        selections = set()
        
        try:
            if user_input == '99':
                return list(range(0, 13))
            
            parts = user_input.replace(' ', '').split(',')
            for part in parts:
                if '-' in part:
                    start, end = map(int, part.split('-'))
                    selections.update(range(start, end + 1))
                else:
                    selections.add(int(part))
            
            valid_selections = [s for s in selections if 0 <= s <= 12]
            if valid_selections:
                return sorted(valid_selections)
            else:
                print("Invalid selection. Please enter numbers between 0-12 or 99.")
        except ValueError:
            print("Invalid input. Please use format like: 1,3,5 or 1-12 or 99")

def generate_selected_graphs(selections):
    """Generate the graphs based on user selection"""
    graph_functions = {
        0: ("Data Summary", show_data_summary),
        1: ("Attendance by Category", graph1_attendance_by_category),
        2: ("Total Attendance Trend", graph2_total_attendance_trend),
        3: ("Saturday Service Attendance Pie Chart", graph3_attendance_pie),
        4: ("Tithe vs Offerings", graph4_tithe_vs_offerings),
        5: ("Income Breakdown", graph5_income_breakdown),
        6: ("Income Pie Chart", graph6_income_pie),
        7: ("Attendance vs Income", graph7_attendance_vs_income),
        8: ("Dashboard Summary", graph8_dashboard),
        9: ("Sunday Home Church vs All Funds", graph9_sunday_home_church_vs_funds),
        10: ("Demographics vs Funds", graph10_demographics_vs_funds),
        11: ("Funds vs Total Attendance", graph11_funds_vs_total_attendance),
        12: ("All Groups vs Each Fund (Correlation)", graph12_all_groups_vs_each_fund),
    }
    
    print(f"\n{'='*70}")
    print(f"Generating {len(selections)} selected item(s)...")
    print('='*70)
    
    for selection in selections:
        name, func = graph_functions[selection]
        print(f"\n▶ Generating: {name}")
        func()
    
    print("\n" + "="*70)
    print("Generation complete!")
    print("="*70)

def main():
    """Main program loop"""
    print("\n" + "🏛️ "*10)
    print("  Welcome to Church Data Analysis Tool")
    print("🏛️ "*10)
    
    while True:
        display_menu()
        selections = get_user_selection()
        
        if selections is None:
            print("\nThank you for using Church Data Analysis Tool!")
            print("God bless! 🙏")
            break
        
        generate_selected_graphs(selections)
        
        input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()