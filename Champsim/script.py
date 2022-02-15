import os
import csv
import pandas as pandasForSortingCSV

rootdir = 'results'
for direc in os.listdir(rootdir):
    d = os.path.join(rootdir, direc)
    if os.path.isdir(d):
        with open(d.split("/")[1].split("_")[1] + "_" + d.split("/")[1].split("_")[2] + "_" + d.split("/")[1].split("_")[3] + "_" + "ipc.csv", mode='w') as ipc_csv:
        #mpi_csv = open(d.split("/")[1].split("_")[1] + "_" + d.split("/")[1].split("_")[2] + "_" + d.split("/")[1].split("_")[3] + "_" + "mpi", "w")
            csv_writer = csv.writer(ipc_csv, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for txt_file in os.listdir(d):
                file_var = open(d + '/' + txt_file, "r")
                flag=0
                index=0
                for line in file_var:
                    index += 1
                    if 'CPU 0 cumulative IPC:' in line:
                        flag = 1
                        break
                if flag == 0:
                    print('String no')
                    csv_writer.writerow([txt_file.split(".")[0]])
                else:
                    print('String yes', d, txt_file.split(".")[0], line.split(" ")[4])
                    csv_writer.writerow([txt_file.split(".")[0], line.split(" ")[4]])
                file_var.close()
        ipc_csv = pandasForSortingCSV.read_csv(d.split("/")[1].split("_")[1] + "_" + d.split("/")[1].split("_")[2] + "_" + d.split("/")[1].split("_")[3] + "_" + "ipc.csv")
        csvData.sort_values(csvData.columns[1], axis = 0, inplace = True)

