
   Illuminate\Database\QueryException 

  SQLSTATE[HY000] [1045] Access denied for user 'u743570205_billing'@'localhost' (using password: YES) (SQL: select * from information_schema.tables where table_schema = u743570205_billing and table_name = abilities and table_type = 'BASE TABLE')

  at vendor/laravel/framework/src/Illuminate/Database/Connection.php:712
    708▕         // If an exception occurs when attempting to run a query, we'll format the error
    709▕         // message to include the bindings with SQL, which will make this exception a
    710▕         // lot more helpful to the developer instead of just the database's errors.
    711▕         catch (Exception $e) {
  ➜ 712▕             throw new QueryException(
    713▕                 $query, $this->prepareBindings($bindings), $e
    714▕             );
    715▕         }
    716▕     }

  1   [internal]:0
      Illuminate\Foundation\Application::{closure:Illuminate\Foundation\Application::boot():904}(Object(Crater\Providers\AppServiceProvider))

      [2m+2 vendor frames [22m
  4   [internal]:0
      Illuminate\Foundation\Application::{closure:Illuminate\Foundation\Application::boot():904}(Object(Crater\Providers\AppServiceProvider))
