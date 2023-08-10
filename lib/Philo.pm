package Philo;
use v5.38;

## --------------------------------------------------------
## Core
## --------------------------------------------------------
## The core classes ...
## --------------------------------------------------------

use Philo::Point;
use Philo::Color;
use Philo::Shader;
use Philo::Sprite;

## --------------------------------------------------------
## Tools
## --------------------------------------------------------
## Some useful objects ...
## --------------------------------------------------------

use Philo::Tools::Direction;
use Philo::Tools::ArrowKeys;

## --------------------------------------------------------
## Roles
## --------------------------------------------------------
## Since perl classes do not currently support roles we
## make use of the `roles` pragma (which uses the `MOP`
## module internally) to apply these roles.
##
## The issue is that `roles` (and `MOP`) don't understand
## fields, so these must be restricted to methods only.
##
## Suffice to say, this is very experimental and should
## be used sparingly and carefully.
## --------------------------------------------------------

use roles ();

use Philo::Roles::Drawable;
use Philo::Roles::Oriented;

__END__
