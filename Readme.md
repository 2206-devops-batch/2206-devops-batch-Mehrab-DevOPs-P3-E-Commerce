# Mehrab-DevOPs-P3-E-Commerce

# Backendend

> cd backend
>
> docker build -t othom/e-commerce-backend-blue:latest .
>
> docker run -d -p 5000:5000 othom/e-commerce-backend-blue:latest

# Frontend

> cd frontend
>
> docker build -t othom/e-commerce-frontend-blue:latest .
>
> docker run -d -p 3000:80 othom/e-commerce-frontend-blue:latest

Now go to your browser and open: <http://localhost:3000/>

<!-- ## Prepare your enviornment

in the project back end directory, enter the command

> `mvn install`

Then, navagate into the `target` directory, and run the command:

> `mvn spring-boot:run`

which will run the Spring enviornment

The enviornment will be limited to the test data contained in this source code.

---

To run the front end, navigate to its directory and run the command:

> `npm install`

After that, running the command:

> `npm start`

within the directory will open the application in your browser. -->
