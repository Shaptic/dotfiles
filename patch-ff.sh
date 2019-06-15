#!/bin/bash
ADD=$(
    echo MOZ_USE_XINPUT2=1 MOZ_USE_XINPUT=1 $(
        cat /usr/bin/firefox | grep firefox))
echo "#!/bin/sh" > /usr/bin/firefox
echo $ADD >> /usr/bin/firefox
chmod 0755 /usr/bin/firefox
