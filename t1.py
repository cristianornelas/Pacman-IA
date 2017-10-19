#!/usr/bin/python
# -*- coding: utf-8 -*-

import commands
import Tkinter as tk
import tkMessageBox
import ttk
import sys
import os
import ast
import time

def center(width, height, root):
    """ Set the title, size and position of the window

    Arguments:
    width -- Int (Width of the window)
    height -- Int (Height of the window)
    root -- TK Element (The root element of TKInter)
    """
    root.wm_title("PacMan T1 - IA")
    root.resizable(width=True, height=True)
    frm_width = root.winfo_rootx() - root.winfo_x()
    win_width = width + 2 * frm_width
    titlebar_height = root.winfo_rooty() - root.winfo_y()
    win_height = height + titlebar_height + frm_width
    x = root.winfo_screenwidth() // 2 - win_width // 2
    y = root.winfo_screenheight() // 2 - win_height // 2
    root.geometry('{0}x{1}+{2}+{3}'.format(width, height, x, y))

def getFieldSize(root):
    root.withdraw()
    top = tk.Toplevel()
    center(320,50,top)
    top.protocol("WM_DELETE_WINDOW", sys.exit)

    top.title = "Field Size"
    size = tk.StringVar()

    tk.Label(top, text="Qual o tamanho do campo?").grid(row=0,column=0)
    tk.Entry(top, textvariable=size).grid(row=0,column=1)
    tk.Button(top, text="Ok", command=lambda: buildField(size, root, top)).grid(row=1,column=0, sticky='ew')
    tk.Button(top, text="Cancel", command=sys.exit).grid(row=1,column=1, sticky='ew')

def buildField(size, root, top):
    root.deiconify()
    top.destroy()

    currDir = os.getcwd()
    resDir = os.path.join(currDir, "res")

    ghost = tk.PhotoImage(file=os.path.join(resDir, "ghost.gif"))
    pacman = tk.PhotoImage(file=os.path.join(resDir, "pacman.gif"))
    fruta = tk.PhotoImage(file=os.path.join(resDir, "fruit.gif"))
    point = tk.PhotoImage(file=os.path.join(resDir, "point.gif"))

    size = int(size.get())

    center(size * 50 + 100, size* 50, root)
    fieldCells = []
    fieldValues = []

    for i in range(size):
        row = []
        rowValues = []
        for j in range(size):
            button = tk.Button(root, bg="white", width="3", height="2",  borderwidth=2, relief="ridge", command=lambda newI=i, newJ=j: setImage(fieldCells, fieldValues, newI, newJ))
            button.grid(row=i, column=j)
            row.append(button)
            rowValues.append(0)
        fieldCells.append(row)
        fieldValues.append(rowValues)
    
    pacmanSelector = tk.Button(root, image = pacman, bg="white", width="40", height="40", command= lambda: selectElement(1))
    pacmanSelector.image = pacman
    pacmanSelector.grid(row = 0, column = size, padx=20)

    ghostSelector = tk.Button(root, image = ghost, bg="white", width="40", height="40", command= lambda: selectElement(2))
    ghostSelector.image = ghost
    ghostSelector.grid(row = 1, column = size)

    frutaSelector = tk.Button(root, image = fruta, bg="white", width="40", height="40", command= lambda: selectElement(4))
    frutaSelector.image = fruta
    frutaSelector.grid(row = 2, column = size)

    pointSelector = tk.Button(root, image = point,  bg="white", width="40", height="40", command= lambda: selectElement(3))
    pointSelector.image = point
    pointSelector.grid(row = 3, column = size)

    start = tk.Button(root, text = "Start!", command= lambda: play(fieldValues, root))
    start.grid(row = 4, column = size)

def setImage(fieldCells, fieldValue, i, j):
    currDir = os.getcwd()
    resDir = os.path.join(currDir, "res")

    ghost = tk.PhotoImage(file=os.path.join(resDir, "ghost.gif"))
    pacman = tk.PhotoImage(file=os.path.join(resDir, "pacman.gif"))
    fruta = tk.PhotoImage(file=os.path.join(resDir, "fruit.gif"))
    point = tk.PhotoImage(file=os.path.join(resDir, "point.gif"))

    if selectedElem == 1:
        fieldCells[i][j].config(image = pacman, width=46, height=36)
        fieldCells[i][j].image = pacman
        fieldCells[i][j].update()
        fieldValue[i][j] = 1
    elif selectedElem == 2:
        fieldCells[i][j].config(image = ghost, width=46, height=36)
        fieldCells[i][j].image = ghost
        fieldCells[i][j].update()
        fieldValue[i][j] = 2
    elif selectedElem == 3:
        fieldCells[i][j].config(image = point, width=46, height=36)
        fieldCells[i][j].image = point
        fieldCells[i][j].update()
        fieldValue[i][j] = 3
    elif selectedElem == 4:
        fieldCells[i][j].config(image = fruta, width=46, height=36)
        fieldCells[i][j].image = fruta
        fieldCells[i][j].update()
        fieldValue[i][j] = 4

def selectElement(element):
    global selectedElem
    selectedElem = element

def getGoalState(fieldValues):
    objetivo = []
    for i in range(len(fieldValues)):
        row = []
        for j in range(len(fieldValues[0])):
            if fieldValues[i][j] == 4:
                row.append(1)
            else:
                row.append(0)
        objetivo.append(row)

    return objetivo

def getGoalPosition(fieldValues):
    i = 0
    j = 0

    for row in fieldValues:
        j = 0
        for col in row:
            if fieldValues[i][j] == 4:
                return (i, j)
            else:
                j += 1
        i += 1

def getNumberOfMonsters(fieldValues):
    count = 0
    for row in fieldValues:
        for col in row:
            if col == 2:
                count += 1
    return count

def play(fieldValues, root):
    print("echo 'play({0}, {1}).' | swipl -q -f t1.pl".format(str(getGoalState(fieldValues)), str([[fieldValues]]).replace('4', '0')))
    caminho = commands.getoutput("echo 'play({0}, {1}).' | swipl -q -f t1.pl".format(str(getGoalState(fieldValues)), str([[fieldValues]]).replace('4', '0')))
    
    if getNumberOfMonsters < 4:
        tkMessageBox.showerror("Numero de fantasmas", "O numero minimo de fanstasmas é 4.")
        sys.exit()

    currDir = os.getcwd()
    resDir = os.path.join(currDir, "res")

    ghost = tk.PhotoImage(file=os.path.join(resDir, "ghost.gif"))
    pacman = tk.PhotoImage(file=os.path.join(resDir, "pacman.gif"))
    fruta = tk.PhotoImage(file=os.path.join(resDir, "fruit.gif"))
    point = tk.PhotoImage(file=os.path.join(resDir, "point.gif"))

    goalPosition = getGoalPosition(fieldValues)

    if caminho.split()[1] == "true.":        
        path = ast.literal_eval(caminho.split()[0])
        path.reverse()
        for estado in path:
            
            if path.index(estado) < len(path) - 1:
                estado[goalPosition[0]][goalPosition[1]] = 4
            
            for i in range(len(estado)):
                for j in range(len(estado[0])):
                    if estado[i][j] == 0:
                        button = tk.Button(root, bg="white", width="3", height="2",  borderwidth=2, relief="ridge").grid(row=i, column=j)
                    if estado[i][j] == 1:
                        button = tk.Button(root, bg="white", image=pacman, width=46, height=36,  borderwidth=2, relief="ridge")
                        button.image = pacman
                        button.grid(row=i, column=j)
                    if estado[i][j] == 2:
                        button = tk.Button(root, bg="white", image = ghost, width=46, height=36,  borderwidth=2, relief="ridge")
                        button.image = ghost
                        button.grid(row=i, column=j)
                    if estado[i][j] == 3:
                        button = tk.Button(root, bg="white", image = point, width=46, height=36,  borderwidth=2, relief="ridge")
                        button.image = point
                        button.grid(row=i, column=j)
                    if estado[i][j] == 4:
                        button = tk.Button(root, bg="white", image = fruta, width=46, height=36,  borderwidth=2, relief="ridge")
                        button.image = fruta
                        button.grid(row=i, column=j)
                    root.update()
            time.sleep(0.5)
    else:
        tkMessageBox.showerror("Prolog Output", caminho.split()[1])

                        
selectedElem = 1
root = tk.Tk()
getFieldSize(root)
root.mainloop()