 <?php

    // aid of the highlighted Alliance
    $marked_aid = 2403;
    
    // Preferences
    $mysqlhost = 'localhost';
    $mysqluser = 'user';
    $mysqlpass = 'password';
    $mysqldb = 'database';
    
    // Create database connection and select database
    $db = @mysql_connect($mysqlhost, $mysqluser, $mysqlpass) OR die('Can not connect to DB-Server!');
    $db_select = @mysql_select_db($mysqldb) OR die('Can not select DB!');
    
    // Create image: Map goes from -400 to 400
    // -> sums up tp 2*400+1 (+1 due to the 0 in the center)
    $image = imagecreate(801, 801);
    
    // Choose the colors of background, normal village and highlighted alliance
    $color_background = imagecolorallocate($image, 255, 255, 255);
    $color_normal = imagecolorallocate($image, 200, 200, 200);
    $color_marked = imagecolorallocate($image, 255, 0, 0);

    // Fill images background with chosen color
    imagefill($image, 0, 0, $color_background);

    // Select ALL villages from the DB and order by ascending ID
    // (Fields are numbered from top left to bottom right)
    $query = 'SELECT x, y, aid FROM x_world ORDER BY id ASC';
    $result = @mysql_query($query) OR die('Can not select villages from table x_world!');
    
    // Check whether there any villages at all
    if (mysql_num_rows($result)) {
        
        // Select first village
        $row = @mysql_fetch_assoc($result);
        
        // These variables save the location on which we are currently drawing
        $x_pointer = 0;
        $y_pointer = 0;
        
        // Outer loop for the Y-coordinates
        for($y=400; $y >= -400; $y--) {
        
            // Inner loop for the X-coordinates
            for ($x=-400; $x <= 400; $x++) {
                
                // Once we reached the coordinates matching the current record selected from the DB:
                if ($row['x'] == $x AND $row['y'] == $y) {
                    
                    // Selecting the village color depending on the aid
                    if ($row['aid'] == $marked_aid) {
                        $color = $color_marked;
                    } else {
                        $color = $color_normal;
                    }
                    
                    // Drawing the village with the selected color
                    imagefilledrectangle($image, $x_pointer, $y_pointer, ($x_pointer + 1), ($y_pointer + 1), $color);
                    
                    // Select next record
                    $row = @mysql_fetch_assoc($result);
                }
                
                // Increase pointer for X-coordinate
                $x_pointer++;
            }
            
            // Increase pointer for Y-coordinate
            $y_pointer++;
            
            // We reached the end of a line and have to set the X-pointer to 0 again
            $x_pointer = 0;
        }    
    }
    
    // Select the HTTP-Header for the selected filetype
    header("Content-Type: image/png");
    
    // Generate image and print it
    imagepng($image);

?>
