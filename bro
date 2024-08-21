package assignment;

import java.io.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

class Hall {
    private String hallId;
    private String name;
    private String type;
    private int capacity;
    private double bookingRate;

    public static final Hall AUDITORIUM = new Hall("H1", "Auditorium", "Large", 1000, 300.00);
    public static final Hall BANQUET_HALL = new Hall("H2", "Banquet Hall", "Medium", 300, 100.00);
    public static final Hall MEETING_ROOM = new Hall("H3", "Meeting Room", "Small", 30, 50.00);

    public Hall(String hallId, String name, String type, int capacity, double bookingRate) {
        this.hallId = hallId;
        this.name = name;
        this.type = type;
        this.capacity = capacity;
        this.bookingRate = bookingRate;
    }

    public String getHallId() {
        return hallId;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public int getCapacity() {
        return capacity;
    }

    public double getBookingRate() {
        return bookingRate;
    }

    @Override
    public String toString() {
        return hallId + "," + name + "," + type + "," + capacity + "," + bookingRate;
    }
}

class Schedule {
    private String hallId;
    private Date startDateTime;
    private Date endDateTime;
    private String remarks;
    private String type;

    public Schedule(String hallId, Date startDateTime, Date endDateTime, String remarks, String type) {
        this.hallId = hallId;
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.remarks = remarks;
        this.type = type;
    }

    public String getHallId() {
        return hallId;
    }

    public Date getStartDateTime() {
        return startDateTime;
    }

    public Date getEndDateTime() {
        return endDateTime;
    }

    public String getType() {
        return type;
    }

    @Override
    public String toString() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return hallId + "," + dateFormat.format(startDateTime) + "," + dateFormat.format(endDateTime) + "," + remarks + "," + type;
    }
}

class User {
    private String username;
    private String password;
    private String role;

    public User(String username, String password, String role) {
        this.username = username;
        this.password = password;
        this.role = role;
    }

    public String getUsername() {
        return username;
    }

    public String getRole() {
        return role;
    }

    public boolean authenticate(String password) {
        return this.password.equals(password);
    }

    @Override
    public String toString() {
        return "Username: " + username + ", Role: " + role;
    }
}

class Admin extends User {
    public Admin(String username, String password) {
        super(username, password, "Admin");
    }
}

class Customer extends User {
    private String contactInfo;
    private String email;
    private String phoneNumber;

    public Customer(String username, String password, String contactInfo, String email, String phoneNumber) {
        super(username, password, "Customer");
        this.contactInfo = contactInfo;
        this.email = email;
        this.phoneNumber = phoneNumber;
    }

    @Override
    public String toString() {
        return super.toString() + ", Contact Info: " + contactInfo + ", Email: " + email + ", Phone: " + phoneNumber;
    }
}

class Scheduler extends User {
    public Scheduler(String username, String password) {
        super(username, password, "Scheduler");
    }
}

class SchedulerSystem {
    private List<Hall> halls = new ArrayList<>();
    private List<Schedule> schedules = new ArrayList<>();
    private List<User> users = new ArrayList<>();

    public SchedulerSystem() {
        halls.add(Hall.AUDITORIUM);
        halls.add(Hall.BANQUET_HALL);
        halls.add(Hall.MEETING_ROOM);
    }

    public void addUser(User user) {
        users.add(user);
    }

    public User findUserByUsername(String username) {
        for (User user : users) {
            if (user.getUsername().equalsIgnoreCase(username)) {
                return user;
            }
        }
        return null;
    }

    public User authenticateUser(String username, String password) {
        User user = findUserByUsername(username);
        if (user != null && user.authenticate(password)) {
            return user;
        }
        return null;
    }

    public boolean isHallAvailable(String hallId, Date startDateTime, Date endDateTime) {
        Calendar cal = Calendar.getInstance();
        for (Schedule schedule : schedules) {
            if (schedule.getHallId().equals(hallId)) {
                cal.setTime(schedule.getStartDateTime());
                cal.add(Calendar.MINUTE, -30);
                Date bufferStartTime = cal.getTime();

                cal.setTime(schedule.getEndDateTime());
                cal.add(Calendar.MINUTE, 30);
                Date bufferEndTime = cal.getTime();

                if ((startDateTime.before(bufferEndTime) && startDateTime.after(bufferStartTime)) ||
                    (endDateTime.before(bufferEndTime) && endDateTime.after(bufferStartTime)) ||
                    startDateTime.equals(schedule.getStartDateTime()))) {
                    return false;
                }
            }
        }
        return true;
    }

    public void scheduleEvent(String hallId, Date startDateTime, Date endDateTime, String eventType) {
        if (isHallAvailable(hallId, startDateTime, endDateTime)) {
            Schedule newSchedule = new Schedule(hallId, startDateTime, endDateTime, eventType, "Scheduled Event");
            schedules.add(newSchedule);
            System.out.println("Event scheduled in " + hallId + " from " + startDateTime + " to " + endDateTime);
        } else {
            System.out.println("The hall is not available during the requested time.");
        }
    }

    public void cancelSchedule(String hallId, Date startDateTime) {
        Iterator<Schedule> iterator = schedules.iterator();
        while (iterator.hasNext()) {
            Schedule schedule = iterator.next();
            if (schedule.getHallId().equals(hallId) && schedule.getStartDateTime().equals(startDateTime)) {
                iterator.remove();
                System.out.println("Schedule cancelled for hall " + hallId + " starting at " + startDateTime);
                return;
            }
        }
        System.out.println("No matching schedule found to cancel.");
    }

    public void modifySchedule(String hallId, Date oldStartDateTime, Date newStartDateTime, Date newEndDateTime, String newEventType) {
        for (Schedule schedule : schedules) {
            if (schedule.getHallId().equals(hallId) && schedule.getStartDateTime().equals(oldStartDateTime)) {
                if (isHallAvailable(hallId, newStartDateTime, newEndDateTime)) {
                    schedule = new Schedule(hallId, newStartDateTime, newEndDateTime, newEventType, "Scheduled Event");
                    System.out.println("Schedule modified for hall " + hallId + " with new time " + newStartDateTime + " to " + newEndDateTime);
                } else {
                    System.out.println("The hall is not available during the new requested time.");
                }
                return;
            }
        }
        System.out.println("No matching schedule found to modify.");
    }

    public void viewAllSchedules() {
        if (schedules.isEmpty()) {
            System.out.println("No schedules found.");
        } else {
            for (Schedule schedule : schedules) {
                System.out.println(schedule);
            }
        }
    }

    public void viewSpecificHallSchedules(String hallId) {
        boolean found = false;
        for (Schedule schedule : schedules) {
            if (schedule.getHallId().equals(hallId)) {
                System.out.println(schedule);
                found = true;
            }
        }
        if (!found) {
            System.out.println("No schedules found for hall " + hallId);
        }
    }

    public void saveData() {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("data.dat"))) {
            oos.writeObject(halls);
            oos.writeObject(schedules);
            oos.writeObject(users);
            System.out.println("Data saved successfully.");
        } catch (IOException e) {
            System.out.println("Error saving data: " + e.getMessage());
        }
    }

    public void loadData() {
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream("data.dat"))) {
            halls = (List<Hall>) ois.readObject();
            schedules = (List<Schedule>) ois.readObject();
            users = (List<User>) ois.readObject();
            System.out.println("Data loaded successfully.");
        } catch (IOException | ClassNotFoundException e) {
            System.out.println("Error loading data: " + e.getMessage());
        }
    }

    public List<Schedule> getSchedules() {
        return schedules;
    }

    public Hall getHallById(String hallId) {
        for (Hall hall : halls) {
            if (hall.getHallId().equals(hallId)) {
                return hall;
            }
        }
        return null;
    }

    public void addSchedule(Schedule schedule) {
        schedules.add(schedule);
    }
}

public class HallBookingSystem {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        SchedulerSystem schedulerSystem = new SchedulerSystem();
        schedulerSystem.loadData();

        Scheduler scheduler = new Scheduler("scheduler", "schedulerpass");
        schedulerSystem.addUser(scheduler);

        System.out.println("Welcome to the Hall Booking System");

        User loggedInUser = null;
        while (loggedInUser == null) {
            System.out.print("Enter username: ");
            String username = scanner.nextLine().trim();
            User user = schedulerSystem.findUserByUsername(username);

            if (user == null) {
                System.out.println("Wrong username. Please try again.");
                continue;
            }

            System.out.print("Enter password: ");
            String password = scanner.nextLine();

            if (user.authenticate(password)) {
                loggedInUser = user;
            } else {
                System.out.println("Wrong password. Please try again.");
            }
        }

        if (loggedInUser instanceof Scheduler) {
            System.out.println("Scheduler logged in successfully.");
            schedulerMenu(scanner, schedulerSystem, (Scheduler) loggedInUser);
        }

        schedulerSystem.saveData();
        scanner.close();
    }

    private static void schedulerMenu(Scanner scanner, SchedulerSystem schedulerSystem, Scheduler scheduler) {
        int choice;
        do {
            System.out.println("\nScheduler Menu:");
            System.out.println("1. View All Schedules");
            System.out.println("2. Check Hall Availability");
            System.out.println("3. Schedule an Event or Recurring Event");
            System.out.println("4. Modify or Cancel a Schedule");
            System.out.println("5. Search Events by Type");
            System.out.println("6. Generate Booking Report");
            System.out.println("7. Export/Import Schedule Data");
            System.out.println("8. Manage Profile");
            System.out.println("9. Exit");
            System.out.print("Enter your choice: ");
            while (!scanner.hasNextInt()) {
                System.out.println("Invalid input. Please enter a number between 1 and 9.");
                System.out.print("Enter your choice: ");
                scanner.next(); // Clear the invalid input
            }
            choice = scanner.nextInt();
            scanner.nextLine(); // Consume newline

            switch (choice) {
                case 1:
                    schedulerSystem.viewAllSchedules();
                    break;
                case 2:
                    checkHallAvailability(scanner, schedulerSystem);
                    break;
                case 3:
                    scheduleEvent(scanner, schedulerSystem);
                    break;
                case 4:
                    modifyOrCancelSchedule(scanner, schedulerSystem);
                    break;
                case 5:
                    searchEventsByType(scanner, schedulerSystem);
                    break;
                case 6:
                    generateBookingReport(scanner, schedulerSystem);
                    break;
                case 7:
                    exportImportScheduleData(scanner, schedulerSystem);
                    break;
                case 8:
                    manageProfile(scanner, scheduler);
                    break;
                case 9:
                    System.out.println("Exiting scheduler menu.");
                    break;
                default:
                    System.out.println("Invalid choice, please try again.");
            }
        } while (choice != 9);
    }

    private static void checkHallAvailability(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Enter hall ID to check availability or type 'back' to return: ");
        String hallId = scanner.nextLine();
        if (hallId.equalsIgnoreCase("back")) return;

        System.out.print("Enter start date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String startStr = scanner.nextLine();
        if (startStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter end date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String endStr = scanner.nextLine();
        if (endStr.equalsIgnoreCase("back")) return;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Date startDateTime, endDateTime;
        try {
            startDateTime = sdf.parse(startStr);
            endDateTime = sdf.parse(endStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        if (schedulerSystem.isHallAvailable(hallId, startDateTime, endDateTime)) {
            System.out.println("The hall is available during the requested time.");
        } else {
            System.out.println("The hall is not available during the requested time.");
        }
    }

    private static void scheduleEvent(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.println("\nAvailable Halls:");
        System.out.println("1. Auditorium (Large, Seats 1000, RM 300/hour)");
        System.out.println("2. Banquet Hall (Medium, Seats 300, RM 100/hour)");
        System.out.println("3. Meeting Room (Small, Seats 30, RM 50/hour)");
        System.out.print("Select hall by number or type 'back' to return to the Scheduler Menu: ");
        String hallChoice = scanner.nextLine();
        if (hallChoice.equalsIgnoreCase("back")) return;

        Hall selectedHall = null;
        switch (hallChoice) {
            case "1":
                selectedHall = Hall.AUDITORIUM;
                break;
            case "2":
                selectedHall = Hall.BANQUET_HALL;
                break;
            case "3":
                selectedHall = Hall.MEETING_ROOM;
                break;
            default:
                System.out.println("Invalid hall selection. Please try again.");
                return;
        }

        String[] eventTypes = {"Conference", "Wedding", "Meeting", "Workshop", "Seminar", "Other"};
        System.out.println("Select an event type:");
        for (int i = 0; i < eventTypes.length; i++) {
            System.out.println((i + 1) + ". " + eventTypes[i]);
        }
        System.out.print("Enter the number corresponding to the event type or type 'back' to return: ");
        String eventTypeChoice = scanner.nextLine();
        if (eventTypeChoice.equalsIgnoreCase("back")) return;

        int eventTypeIndex;
        try {
            eventTypeIndex = Integer.parseInt(eventTypeChoice) - 1;
            if (eventTypeIndex < 0 || eventTypeIndex >= eventTypes.length) {
                System.out.println("Invalid event type selection. Please try again.");
                return;
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid event type selection. Please try again.");
            return;
        }

        String eventType = eventTypes[eventTypeIndex];

        System.out.print("Is this a recurring event? (yes/no): ");
        String recurring = scanner.nextLine();
        boolean isRecurring = recurring.equalsIgnoreCase("yes");

        if (isRecurring) {
            scheduleRecurringEvent(scanner, schedulerSystem, selectedHall, eventType);
        } else {
            scheduleSingleEvent(scanner, schedulerSystem, selectedHall, eventType);
        }
    }

    private static void scheduleSingleEvent(Scanner scanner, SchedulerSystem schedulerSystem, Hall selectedHall, String eventType) {
        System.out.print("Enter start date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String startStr = scanner.nextLine();
        if (startStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter end date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String endStr = scanner.nextLine();
        if (endStr.equalsIgnoreCase("back")) return;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Date startDateTime, endDateTime;
        try {
            startDateTime = sdf.parse(startStr);
            endDateTime = sdf.parse(endStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        schedulerSystem.scheduleEvent(selectedHall.getHallId(), startDateTime, endDateTime, eventType);
    }

    private static void scheduleRecurringEvent(Scanner scanner, SchedulerSystem schedulerSystem, Hall selectedHall, String eventType) {
        System.out.print("Enter start date and time of the first occurrence (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String startStr = scanner.nextLine();
        if (startStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter end date and time of the first occurrence (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String endStr = scanner.nextLine();
        if (endStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter recurrence interval (daily, weekly, monthly): ");
        String recurrence = scanner.nextLine();

        System.out.print("Enter the number of occurrences: ");
        int occurrences = scanner.nextInt();
        scanner.nextLine(); // Consume newline

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Date startDateTime, endDateTime;
        try {
            startDateTime = sdf.parse(startStr);
            endDateTime = sdf.parse(endStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        Calendar calendar = Calendar.getInstance();
        for (int i = 0; i < occurrences; i++) {
            schedulerSystem.scheduleEvent(selectedHall.getHallId(), startDateTime, endDateTime, eventType);
            calendar.setTime(startDateTime);

            switch (recurrence.toLowerCase()) {
                case "daily":
                    calendar.add(Calendar.DAY_OF_MONTH, 1);
                    break;
                case "weekly":
                    calendar.add(Calendar.WEEK_OF_YEAR, 1);
                    break;
                case "monthly":
                    calendar.add(Calendar.MONTH, 1);
                    break;
                default:
                    System.out.println("Invalid recurrence interval. Scheduling stopped.");
                    return;
            }
            startDateTime = calendar.getTime();
            calendar.setTime(endDateTime);
            endDateTime = calendar.getTime();
        }
    }

    private static void modifyOrCancelSchedule(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Enter hall ID to modify or cancel a schedule or type 'back' to return: ");
        String hallId = scanner.nextLine();
        if (hallId.equalsIgnoreCase("back")) return;

        System.out.print("Enter start date and time of the schedule (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String startStr = scanner.nextLine();
        if (startStr.equalsIgnoreCase("back")) return;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Date startDateTime;
        try {
            startDateTime = sdf.parse(startStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        System.out.print("Do you want to modify or cancel this schedule? (modify/cancel): ");
        String action = scanner.nextLine();

        if (action.equalsIgnoreCase("modify")) {
            modifySchedule(scanner, schedulerSystem, hallId, startDateTime);
        } else if (action.equalsIgnoreCase("cancel")) {
            schedulerSystem.cancelSchedule(hallId, startDateTime);
        } else {
            System.out.println("Invalid choice. Please try again.");
        }
    }

    private static void modifySchedule(Scanner scanner, SchedulerSystem schedulerSystem, String hallId, Date oldStartDateTime) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        System.out.print("Enter new start date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String newStartStr = scanner.nextLine();
        if (newStartStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter new end date and time (yyyy-MM-dd HH:mm) or type 'back' to return: ");
        String newEndStr = scanner.nextLine();
        if (newEndStr.equalsIgnoreCase("back")) return;

        Date newStartDateTime, newEndDateTime;
        try {
            newStartDateTime = sdf.parse(newStartStr);
            newEndDateTime = sdf.parse(newEndStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        String[] eventTypes = {"Conference", "Wedding", "Meeting", "Workshop", "Seminar", "Other"};
        System.out.println("Select new event type:");
        for (int i = 0; i < eventTypes.length; i++) {
            System.out.println((i + 1) + ". " + eventTypes[i]);
        }
        System.out.print("Enter the number corresponding to the new event type or type 'back' to return: ");
        String eventTypeChoice = scanner.nextLine();
        if (eventTypeChoice.equalsIgnoreCase("back")) return;

        int eventTypeIndex;
        try {
            eventTypeIndex = Integer.parseInt(eventTypeChoice) - 1;
            if (eventTypeIndex < 0 || eventTypeIndex >= eventTypes.length) {
                System.out.println("Invalid event type selection. Please try again.");
                return;
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid event type selection. Please try again.");
            return;
        }

        String newEventType = eventTypes[eventTypeIndex];

        schedulerSystem.modifySchedule(hallId, oldStartDateTime, newStartDateTime, newEndDateTime, newEventType);
    }

    private static void searchEventsByType(Scanner scanner, SchedulerSystem schedulerSystem) {
        String[] eventTypes = {"Conference", "Wedding", "Meeting", "Workshop", "Seminar", "Other"};
        System.out.println("Select an event type to search:");
        for (int i = 0; i < eventTypes.length; i++) {
            System.out.println((i + 1) + ". " + eventTypes[i]);
        }
        System.out.print("Enter the number corresponding to the event type or type 'back' to return: ");
        String eventTypeChoice = scanner.nextLine();
        if (eventTypeChoice.equalsIgnoreCase("back")) return;

        int eventTypeIndex;
        try {
            eventTypeIndex = Integer.parseInt(eventTypeChoice) - 1;
            if (eventTypeIndex < 0 || eventTypeIndex >= eventTypes.length) {
                System.out.println("Invalid event type selection. Please try again.");
                return;
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid event type selection. Please try again.");
            return;
        }

        String eventType = eventTypes[eventTypeIndex];
        boolean found = false;
        for (Schedule schedule : schedulerSystem.getSchedules()) {
            if (schedule.getType().equalsIgnoreCase(eventType)) {
                System.out.println(schedule);
                found = true;
            }
        }
        if (!found) {
            System.out.println("No events of type '" + eventType + "' found.");
        }
    }

    private static void generateBookingReport(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Enter start date (yyyy-MM-dd) or type 'back' to return: ");
        String startStr = scanner.nextLine();
        if (startStr.equalsIgnoreCase("back")) return;

        System.out.print("Enter end date (yyyy-MM-dd) or type 'back' to return: ");
        String endStr = scanner.nextLine();
        if (endStr.equalsIgnoreCase("back")) return;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate, endDate;
        try {
            startDate = sdf.parse(startStr);
            endDate = sdf.parse(endStr);
        } catch (ParseException e) {
            System.out.println("Invalid date format. Please try again.");
            return;
        }

        int totalEvents = 0;
        int totalHoursBooked = 0;
        double totalRevenue = 0.0;
        Map<String, Integer> eventCounts = new HashMap<>();
        Map<String, Integer> hallCounts = new HashMap<>();
        Map<String, Double> hallRevenues = new HashMap<>();

        for (Schedule schedule : schedulerSystem.getSchedules()) {
            if (!schedule.getStartDateTime().before(startDate) && !schedule.getEndDateTime().after(endDate)) {
                totalEvents++;
                int hoursBooked = (int) ((schedule.getEndDateTime().getTime() - schedule.getStartDateTime().getTime()) / (1000 * 60 * 60));
                totalHoursBooked += hoursBooked;

                Hall hall = schedulerSystem.getHallById(schedule.getHallId());
                double revenue = hoursBooked * hall.getBookingRate();
                totalRevenue += revenue;

                hallCounts.put(hall.getName(), hallCounts.getOrDefault(hall.getName(), 0) + 1);
                hallRevenues.put(hall.getName(), hallRevenues.getOrDefault(hall.getName(), 0.0) + revenue);
                eventCounts.put(schedule.getType(), eventCounts.getOrDefault(schedule.getType(), 0) + 1);
            }
        }

        System.out.println("\nBooking Report for " + startStr + " to " + endStr);
        System.out.println("Total Number of Events: " + totalEvents);
        System.out.println("Total Hours Booked: " + totalHoursBooked + " hours");
        System.out.println("Total Revenue Generated: RM " + String.format("%.2f", totalRevenue));

        System.out.println("\nBreakdown by Hall:");
        for (String hallName : hallCounts.keySet()) {
            System.out.println("- " + hallName + ": " + hallCounts.get(hallName) + " events, RM " + String.format("%.2f", hallRevenues.get(hallName)));
        }

        System.out.println("\nBreakdown by Event Type:");
        for (String eventType : eventCounts.keySet()) {
            System.out.println("- " + eventType + ": " + eventCounts.get(eventType) + " events");
        }

        // Optionally, prompt the user to export the report to a CSV file
    }

    private static void exportImportScheduleData(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Do you want to export or import schedule data? (export/import): ");
        String action = scanner.nextLine();

        if (action.equalsIgnoreCase("export")) {
            exportScheduleData(scanner, schedulerSystem);
        } else if (action.equalsIgnoreCase("import")) {
            importScheduleData(scanner, schedulerSystem);
        } else {
            System.out.println("Invalid choice. Please try again.");
        }
    }

    private static void exportScheduleData(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Enter file name to save the data (e.g., schedules.csv): ");
        String fileName = scanner.nextLine();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            for (Schedule schedule : schedulerSystem.getSchedules()) {
                writer.write(schedule.toString());
                writer.newLine();
            }
            System.out.println("Schedule data exported successfully to " + fileName);
        } catch (IOException e) {
            System.out.println("Error exporting schedule data: " + e.getMessage());
        }
    }

    private static void importScheduleData(Scanner scanner, SchedulerSystem schedulerSystem) {
        System.out.print("Enter file name to import the data from (e.g., schedules.csv): ");
        String fileName = scanner.nextLine();

        try (BufferedReader reader = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] data = line.split(",");
                // Assuming the data is in the format: hallId, startDateTime, endDateTime, remarks, type
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String hallId = data[0];
                Date startDateTime = sdf.parse(data[1]);
                Date endDateTime = sdf.parse(data[2]);
                String remarks = data[3];
                String type = data[4];
                Schedule schedule = new Schedule(hallId, startDateTime, endDateTime, remarks, type);
                schedulerSystem.addSchedule(schedule);
            }
            System.out.println("Schedule data imported successfully from " + fileName);
        } catch (IOException | ParseException e) {
            System.out.println("Error importing schedule data: " + e.getMessage());
        }
    }

    private static void manageProfile(Scanner scanner, Scheduler scheduler) {
        System.out.print("Enter new password or type 'back' to return: ");
        String newPassword = scanner.nextLine();
        if (newPassword.equalsIgnoreCase("back")) return;

        scheduler.setPassword(newPassword);
        System.out.println("Password updated successfully.");
    }
}
