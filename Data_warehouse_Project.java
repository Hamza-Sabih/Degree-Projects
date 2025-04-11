/*
 * CODE THAT TAKES CRENDENTIALS
 package DWProject;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;

public class DWProject {
    public static void main(String[] args) throws IOException {
        Connection con = null;
        PreparedStatement pstmt = null;
        PreparedStatement productStmt = null;
        PreparedStatement storeStmt = null;
        PreparedStatement supplierStmt = null;
        PreparedStatement timeStmt = null;
        PreparedStatement customerStmt = null;
        ResultSet rs = null;
        BufferedReader reader = null;

        String filePath = "C:\\Users\\Neelofar Wasi\\Desktop\\Semester 5\\Data Warehousing\\transactions.csv";

        try {
            // Get database credentials from user
            Scanner scanner = new Scanner(System.in);
            System.out.println("Enter MySQL database URL (e.g., jdbc:mysql://localhost:3306/dw): ");
            String dbUrl = scanner.nextLine();
            System.out.println("Enter MySQL username: ");
            String dbUser = scanner.nextLine();
            System.out.println("Enter MySQL password: ");
            String dbPassword = scanner.nextLine();

            // Establish the database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            System.out.println("Connection established successfully!");

            // Prepare SQL statements
            String salesInsertSQL = "INSERT INTO sales (time_id, storeID, supplierID, productID, OrderID, customer_id, OrderDate, TOTAL_SALE) "
                                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(salesInsertSQL);

            String productQuerySQL = "SELECT productPrice, supplierID, storeID FROM Product WHERE productID = ?";
            productStmt = con.prepareStatement(productQuerySQL);

            String timeQuerySQL = "SELECT time_id FROM Date_time WHERE OrderDate = ?";
            timeStmt = con.prepareStatement(timeQuerySQL);

            String customerQuerySQL = "SELECT customer_id FROM customer WHERE customer_id = ?";
            customerStmt = con.prepareStatement(customerQuerySQL);

            // Read the CSV file
            reader = new BufferedReader(new FileReader(filePath));
            String line;
            int rowCount = 0;

            // Read and process each row in the CSV file
            while ((line = reader.readLine()) != null) {
                String[] data = line.split(",");

                // Skip the header row
                if (rowCount == 0) {
                    rowCount++;
                    continue;
                }

                try {
                    int orderID = Integer.parseInt(data[0]); // From CSV
                    String orderDateStr = data[1];          // From CSV
                    int productID = Integer.parseInt(data[2]); // From CSV
                    int quantityOrdered = Integer.parseInt(data[3]); // From CSV
                    int customerID = Integer.parseInt(data[4]); // From CSV
                    int timeID = Integer.parseInt(data[5]); // From CSV (already mapped to Date_time)

                    // Parse the OrderDate field
                    SimpleDateFormat inputDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    SimpleDateFormat outputDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Date orderDate = inputDateFormat.parse(orderDateStr);
                    String formattedOrderDate = outputDateFormat.format(orderDate);

                    // Retrieve productPrice, supplierID, and storeID from the Product table
                    productStmt.setInt(1, productID);
                    rs = productStmt.executeQuery();

                    if (rs.next()) {
                        double productPrice = rs.getDouble("productPrice");
                        int supplierID = rs.getInt("supplierID");
                        int storeID = rs.getInt("storeID");

                        // Validate customer_id exists in the customer dimension
                        customerStmt.setInt(1, customerID);
                        ResultSet customerRs = customerStmt.executeQuery();

                        if (!customerRs.next()) {
                            System.out.println("CustomerID " + customerID + " not found. Skipping row: " + line);
                            continue;
                        }

                        // Calculate TOTAL_SALE
                        double totalSale = quantityOrdered * productPrice;

                        // Insert into the sales fact table
                        pstmt.setInt(1, timeID);              // time_id from CSV
                        pstmt.setInt(2, storeID);             // storeID from Product table
                        pstmt.setInt(3, supplierID);          // supplierID from Product table
                        pstmt.setInt(4, productID);           // From CSV
                        pstmt.setInt(5, orderID);             // From CSV
                        pstmt.setInt(6, customerID);          // From CSV
                        pstmt.setString(7, formattedOrderDate); // Parsed order date
                        pstmt.setDouble(8, totalSale);        // Computed TOTAL_SALE

                        pstmt.executeUpdate();
                        System.out.println("Inserted row for OrderID: " + orderID);
                    } else {
                        System.out.println("ProductID " + productID + " not found in Product table. Skipping row: " + line);
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Skipping row due to invalid numeric data: " + line);
                } catch (ParseException e) {
                    System.out.println("Skipping row due to invalid date format: " + line);
                }
            }

            System.out.println("Data processing complete!");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (reader != null) reader.close();
                if (productStmt != null) productStmt.close();
                if (timeStmt != null) timeStmt.close();
                if (customerStmt != null) customerStmt.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}

 */

package DWProject;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DWProject {
    public static void main(String[] args) throws IOException {
        Connection con = null;
        PreparedStatement pstmt = null;
        PreparedStatement productStmt = null;
        PreparedStatement storeStmt = null;
        PreparedStatement supplierStmt = null;
        PreparedStatement timeStmt = null;
        PreparedStatement customerStmt = null;
        ResultSet rs = null;
        BufferedReader reader = null;

        String filePath = "C:\\Users\\Neelofar Wasi\\Desktop\\Semester 5\\Data Warehousing\\transactions.csv";

        try {
            // Establish the database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/dw", "root", "mrskoochi1024");
            System.out.println("Connection established successfully!");

            // Prepare SQL statements
            String salesInsertSQL = "INSERT INTO sales (time_id, storeID, supplierID, productID, OrderID, customer_id, OrderDate, TOTAL_SALE) "
                                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(salesInsertSQL);

            String productQuerySQL = "SELECT productPrice, supplierID, storeID FROM Product WHERE productID = ?";
            productStmt = con.prepareStatement(productQuerySQL);

            String timeQuerySQL = "SELECT time_id FROM Date_time WHERE OrderDate = ?";
            timeStmt = con.prepareStatement(timeQuerySQL);

            String customerQuerySQL = "SELECT customer_id FROM customer WHERE customer_id = ?";
            customerStmt = con.prepareStatement(customerQuerySQL);

            // Read the CSV file
            reader = new BufferedReader(new FileReader(filePath));
            String line;
            int rowCount = 0;

            // Read and process each row in the CSV file
            while ((line = reader.readLine()) != null) {
                String[] data = line.split(",");

                // Skip the header row
                if (rowCount == 0) {
                    rowCount++;
                    continue;
                }

                try {
                    int orderID = Integer.parseInt(data[0]); // From CSV
                    String orderDateStr = data[1];          // From CSV
                    int productID = Integer.parseInt(data[2]); // From CSV
                    int quantityOrdered = Integer.parseInt(data[3]); // From CSV
                    int customerID = Integer.parseInt(data[4]); // From CSV
                    int timeID = Integer.parseInt(data[5]); // From CSV (already mapped to Date_time)

                    // Parse the OrderDate field
                    SimpleDateFormat inputDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    SimpleDateFormat outputDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Date orderDate = inputDateFormat.parse(orderDateStr);
                    String formattedOrderDate = outputDateFormat.format(orderDate);

                    // Retrieve productPrice, supplierID, and storeID from the Product table
                    productStmt.setInt(1, productID);
                    rs = productStmt.executeQuery();

                    if (rs.next()) {
                        double productPrice = rs.getDouble("productPrice");
                        int supplierID = rs.getInt("supplierID");
                        int storeID = rs.getInt("storeID");

                        // Validate customer_id exists in the customer dimension
                        customerStmt.setInt(1, customerID);
                        ResultSet customerRs = customerStmt.executeQuery();

                        if (!customerRs.next()) {
                            System.out.println("CustomerID " + customerID + " not found. Skipping row: " + line);
                            continue;
                        }

                        // Calculate TOTAL_SALE
                        double totalSale = quantityOrdered * productPrice;

                        // Insert into the sales fact table
                        pstmt.setInt(1, timeID);              // time_id from CSV
                        pstmt.setInt(2, storeID);             // storeID from Product table
                        pstmt.setInt(3, supplierID);          // supplierID from Product table
                        pstmt.setInt(4, productID);           // From CSV
                        pstmt.setInt(5, orderID);             // From CSV
                        pstmt.setInt(6, customerID);          // From CSV
                        pstmt.setString(7, formattedOrderDate); // Parsed order date
                        pstmt.setDouble(8, totalSale);        // Computed TOTAL_SALE

                        pstmt.executeUpdate();
                        System.out.println("Inserted row for OrderID: " + orderID);
                    } else {
                        System.out.println("ProductID " + productID + " not found in Product table. Skipping row: " + line);
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Skipping row due to invalid numeric data: " + line);
                } catch (ParseException e) {
                    System.out.println("Skipping row due to invalid date format: " + line);
                }
            }

            System.out.println("Data processing complete!");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (reader != null) reader.close();
                if (productStmt != null) productStmt.close();
                if (timeStmt != null) timeStmt.close();
                if (customerStmt != null) customerStmt.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}