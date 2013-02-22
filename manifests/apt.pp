#
# pentaho-apt.pp
# 
# Copyright (c) 2011, OSBI Ltd. All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301  USA
#
class pentaho::apt {
  include ::apt
  $apt_key = extlookup('alabs_repo_key', '')
  $apt_content = extlookup('alabs_repo_content', '')

  apt::key { "Analytical Labs":
    source => "${apt_key}",
    require => Apt::Sources_list["analyticallabs"],
  }

  apt::sources_list { "analyticallabs":
    content => "${apt_content}"
  }


}

