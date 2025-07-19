import pandas as pd

# Veriyi oku
df = pd.read_csv('data.csv')

# Ortalama maaş
average_salary = df['Salary'].mean()
print(f"Ortalama Maaş: {average_salary:.2f} TL")

# En yüksek performans skoru
max_performance = df['PerformanceScore'].max()
max_performer = df[df['PerformanceScore'] == max_performance]['Name'].values[0]
print(f"En yüksek performans: {max_performance} (Çalışan: {max_performer})")

# Departmanlara göre ortalama maaş
department_salary_avg = df.groupby('Department')['Salary'].mean()
print("\nDepartmanlara Göre Ortalama Maaşlar:")
print(department_salary_avg)

# 5 yıldan fazla tecrübesi olan çalışan sayısı
experienced_employees = df[df['ExperienceYears'] > 5]
print(f"\n5 yıldan fazla tecrübesi olan çalışan sayısı: {experienced_employees.shape[0]}")
