package com.example.bradycardia;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Scanner;

import android.content.res.AssetManager;
import android.util.Log;

public class kmeans {

    String filename;
    static AssetManager mgr;

    double[][] points_data;
    static ArrayList<Integer>[] clusterList;
    public kmeans(String fileName, AssetManager Mgr) throws IOException {
        //Scanner sc = new Scanner(System.in);
        //String filePath = "";
        //System.out.print("Enter the name of the CSV file: ");
        //String fileName = sc.nextLine();

        // Open the file just to count the number of records
        mgr = Mgr;
        int records = getRecords(fileName);

        //System.out.print("Enter the index of the X-attribute: ");
        int xAttribute = 0;
//		System.out.print("Enter the index of the Y-attribute: ");
        int yAttribute = 1;

        // Open file again to read the records
        points_data = new double[records][2];
        readRecords(fileName, points_data, xAttribute, yAttribute);

        // Sort the points based on X-coordinate values
        sortPointsByX(points_data);

        // Input the number of iterations
//		System.out.print("Enter the maximum number of iterations: ");
        int maxIterations = 10;

        // Input number of clusters
        System.out.print("The number of clusters to form are Two ");
        int clusters = 2;

        // Calculate initial means
        double[][] means = new double[clusters][2];
        for(int i=0; i<means.length; i++) {
            means[i][0] = points_data[(int) (Math.floor((records*1.0/clusters)/2) + i*records/clusters)][0];
            means[i][1] = points_data[(int) (Math.floor((records*1.0/clusters)/2) + i*records/clusters)][1];
        }

        // Create skeletons for clusters
        ArrayList<Integer>[] oldClusters = new ArrayList[clusters];
        ArrayList<Integer>[] newClusters = new ArrayList[clusters];

        for(int i=0; i<clusters; i++) {
            oldClusters[i] = new ArrayList<Integer>();
            newClusters[i] = new ArrayList<Integer>();
        }

        // Make the initial clusters
        formClusters(oldClusters, means, points_data);
        int iterations = 0;

        // Showtime
        while(true) {
            updateMeans(oldClusters, means, points_data);
            formClusters(newClusters, means, points_data);

            iterations++;

            if(iterations > maxIterations || checkEquality(oldClusters, newClusters))
                break;
            else
                resetClusters(oldClusters, newClusters);
        }

        // Display the output
        System.out.println("\nThe final clusters are:");
        clusterList = oldClusters;
        displayOutput(oldClusters, points_data);
        System.out.println("\nIterations taken = " + iterations);
        //double pt = 90.0;
        //System.out.println("Final cluster for point "+ pt +" is  "+ predictclass(pt));


        //sc.close();
    }

    static int getRecords(String fileName) throws IOException {
        int records = 0;
        BufferedReader br = new BufferedReader(new InputStreamReader(mgr.open(fileName)));
        while (br.readLine() != null)
            records++;

        br.close();
        return records;
    }

    static void readRecords(String fileName, double[][] points, int xAttribute, int yAttribute) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(mgr.open(fileName)));
        String line;
        int i = 0;
        while ((line = br.readLine()) != null) {
            points[i][0] = Double.parseDouble(line.split(",")[xAttribute]);
            points[i++][1] = Double.parseDouble(line.split(",")[yAttribute]);
        }

        br.close();
    }

    static void sortPointsByX(double[][] points) {
        double[] temp;

        // Bubble Sort
        for(int i=0; i<points.length; i++)
            for(int j=1; j<(points.length-i); j++)
                if(points[j-1][0] > points[j][0]) {
                    temp = points[j-1];
                    points[j-1] = points[j];
                    points[j] = temp;
                }
    }

    static void updateMeans(ArrayList<Integer>[] clusterList, double[][] means, double[][] points) {
        double totalX = 0;
        double totalY = 0;
        for(int i=0; i<clusterList.length; i++) {
            totalX = 0;
            totalY = 0;
            for(int index: clusterList[i]) {
                totalX += points[index][0];
                totalY += points[index][1];
            }
            means[i][0] = totalX/clusterList[i].size();
            means[i][1] = totalY/clusterList[i].size();
        }
    }

    static void formClusters(ArrayList<Integer>[] clusterList, double[][] means, double[][] points) {
        double distance[] = new double[means.length];
        double minDistance = 999999999;
        int minIndex = 0;

        for(int i=0; i<points.length; i++) {
            minDistance = 999999999;
            for(int j=0; j<means.length; j++) {
                distance[j] = Math.sqrt(Math.pow((points[i][0] - means[j][0]), 2) + Math.pow((points[i][1] - means[j][1]), 2));
                if(distance[j] < minDistance) {
                    minDistance = distance[j];
                    minIndex = j;
                }
            }
            clusterList[minIndex].add(i);
        }
    }

    static boolean checkEquality(ArrayList<Integer>[] oldClusters, ArrayList<Integer>[] newClusters) {
        for(int i=0; i<oldClusters.length; i++) {
            // Check only lengths first
            if(oldClusters[i].size() != newClusters[i].size())
                return false;

            // Check individual values if lengths are equal
            for(int j=0; j<oldClusters[i].size(); j++)
                if(oldClusters[i].get(j) != newClusters[i].get(j))
                    return false;
        }

        return true;
    }

    static void resetClusters(ArrayList<Integer>[] oldClusters, ArrayList<Integer>[] newClusters) {
        for(int i=0; i<newClusters.length; i++) {
            // Copy newClusters to oldClusters
            oldClusters[i].clear();
            for(int index: newClusters[i])
                oldClusters[i].add(index);

            // Clear newClusters
            newClusters[i].clear();
        }
    }

    public int predictclass(double x1)
    {
        Log.d("kmeans:","predict kmeans");
        int res=0;
        double avg = 0.0;
        double centroids[] = new double[2];
        for(int i=0; i<2; i++) {
            avg = 0.0;
            int sz= clusterList[i].size();
            System.out.println(sz);
            for(int index: clusterList[i])
            {

                avg+=points_data[index][0];
                System.out.println(points_data[index][0]);
            }
            centroids[i]= avg/(double)sz;

        }
        System.out.println("centroids[0]");
        System.out.println(centroids[0]);
        System.out.println(centroids[1]);
        System.out.println(x1);
        Log.d("kmeans:",centroids.toString());

        if (centroids[0] < centroids[1] && centroids[0] < 60)
        {
            if(Math.abs(centroids[0] - x1)< Math.abs(centroids[1] - x1))
                res= 1;
            else
                res=0;
        }
        else if(centroids[0] > centroids[1] && centroids[1] < 60)
        {
            if(Math.abs(centroids[0] - x1)> Math.abs(centroids[1] - x1))
                res= 1;
            else
                res=0;
        }
        return res;

    }

    static void displayOutput(ArrayList<Integer>[] clusterList, double[][] points) {
        for(int i=0; i<clusterList.length; i++) {
            String clusterOutput = "\n\n[";
            for(int index: clusterList[i])
                clusterOutput += "(" + points[index][0]  + "), ";
            System.out.println(clusterOutput.substring(0, clusterOutput.length()-2) + "]");
        }
    }
}

